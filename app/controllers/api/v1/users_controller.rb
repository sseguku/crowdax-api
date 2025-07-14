class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /api/v1/users/consent
  def consent
    authorize current_user
    render json: {
      status: { code: 200, message: 'Consent status retrieved.' },
      data: {
        consent_given: current_user.consent_given?,
        consent_given_at: current_user.consent_given_at,
        consent_withdrawn_at: current_user.consent_withdrawn_at,
        consent_version: current_user.consent_version
      }
    }
  end

  # POST /api/v1/users/consent
  def give_consent
    authorize current_user
    version = params[:consent_version] || 'v1.0'
    current_user.give_consent!(version)
    
    # Log consent action
    audit_service = AuditLoggingService.new(request, current_user)
    audit_service.log_consent_action('given', version)
    
    render json: {
      status: { code: 200, message: 'Consent given.' },
      data: {
        consent_given: true,
        consent_given_at: current_user.consent_given_at,
        consent_version: current_user.consent_version
      }
    }
  end

  # DELETE /api/v1/users/consent
  def withdraw_consent
    authorize current_user
    current_user.withdraw_consent!
    
    # Log consent withdrawal
    audit_service = AuditLoggingService.new(request, current_user)
    audit_service.log_consent_action('withdrawn', current_user.consent_version)
    
    render json: {
      status: { code: 200, message: 'Consent withdrawn.' },
      data: {
        consent_given: false,
        consent_withdrawn_at: current_user.consent_withdrawn_at
      }
    }
  end

  # Data Subject Rights Endpoints
  # GET /api/v1/users/data
  def data_subject_data
    authorize current_user
    
    # Log data access
    audit_service = AuditLoggingService.new(request, current_user)
    audit_service.log_data_access(current_user, 'user_data_access')
    
    # Collect all user data
    user_data = {
      profile: {
        id: current_user.id,
        email: current_user.email,
        role: current_user.role,
        created_at: current_user.created_at,
        updated_at: current_user.updated_at,
        consent_given_at: current_user.consent_given_at,
        consent_withdrawn_at: current_user.consent_withdrawn_at,
        consent_version: current_user.consent_version
      },
      kyc: current_user.kyc ? KycSerializer.new(current_user.kyc, { params: { current_user: current_user } }).serializable_hash[:data][:attributes] : nil,
      campaigns: current_user.campaigns.map { |campaign| CampaignSerializer.new(campaign).serializable_hash[:data][:attributes] },
      investments: current_user.investments.map { |investment| InvestmentSerializer.new(investment).serializable_hash[:data][:attributes] }
    }
    
    render json: {
      status: { code: 200, message: 'User data retrieved successfully.' },
      data: user_data
    }
  end

  # PUT /api/v1/users/data
  def update_data_subject_data
    authorize current_user
    
    # Log profile update
    audit_service = AuditLoggingService.new(request, current_user)
    audit_service.log_profile_update(user_data_params.keys)
    
    if current_user.update(user_data_params)
      render json: {
        status: { code: 200, message: 'User data updated successfully.' },
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to update user data.' },
        errors: current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/users/data
  def request_data_deletion
    authorize current_user
    
    # Create deletion request (don't actually delete due to regulatory requirements)
    deletion_request = DataDeletionRequest.create!(
      user: current_user,
      requested_at: Time.current,
      reason: params[:reason],
      status: 'pending'
    )
    
    # Log deletion request
    audit_service = AuditLoggingService.new(request, current_user)
    audit_service.log_deletion_request(deletion_request)
    
    render json: {
      status: { code: 200, message: 'Data deletion request submitted successfully.' },
      data: {
        request_id: deletion_request.id,
        requested_at: deletion_request.requested_at,
        status: deletion_request.status,
        estimated_completion: 30.days.from_now
      }
    }
  end

  # GET /api/v1/users/data/export
  def export_data
    authorize current_user
    
    # Generate comprehensive data export
    export_data = generate_data_export(current_user)
    
    # Create export file
    export_file = create_export_file(export_data, current_user)
    
    # Log data export
    audit_service = AuditLoggingService.new(request, current_user)
    audit_service.log_data_export('user_data_export', export_data.keys.count)
    
    render json: {
      status: { code: 200, message: 'Data export generated successfully.' },
      data: {
        download_url: rails_blob_url(export_file, only_path: true),
        expires_at: 24.hours.from_now,
        file_size: export_file.byte_size
      }
    }
  end

  # GET /api/v1/users/profile
  def profile
    authorize current_user
    render json: {
      status: { code: 200, message: 'User profile retrieved successfully.' },
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    }
  end

  # PUT /api/v1/users/profile
  def update_profile
    authorize current_user
    if current_user.update(user_params)
      render json: {
        status: { code: 200, message: 'Profile updated successfully.' },
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to update profile.' },
        errors: current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /api/v1/users/dashboard
  def dashboard
    authorize current_user, :dashboard?
    render json: {
      status: { code: 200, message: 'Dashboard data retrieved successfully.' },
      data: {
        user: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
        campaigns_count: current_user.campaigns.count,
        investments_count: current_user.investments.count,
        total_invested: current_user.total_invested_amount
      }
    }
  end

  # GET /api/v1/users/admin_dashboard
  def admin_dashboard
    authorize current_user, :admin_dashboard?
    render json: {
      status: { code: 200, message: 'Admin dashboard data retrieved successfully.' },
      data: {
        total_users: User.count,
        total_campaigns: Campaign.count,
        total_investments: Investment.count,
        pending_kycs: Kyc.pending.count
      }
    }
  end

  # GET /api/v1/users/analytics
  def analytics
    authorize current_user, :analytics?
    render json: {
      status: { code: 200, message: 'Analytics data retrieved successfully.' },
      data: {
        user_growth: User.group_by_month(:created_at).count,
        campaign_growth: Campaign.group_by_month(:created_at).count,
        investment_totals: Investment.confirmed.group_by_month(:created_at).sum(:amount)
      }
    }
  end

  # GET /api/v1/users
  def index
    authorize User
    @users = policy_scope(User)
    render json: {
      status: { code: 200, message: 'Users retrieved successfully.' },
      data: @users.map { |user| UserSerializer.new(user).serializable_hash[:data][:attributes] }
    }
  end

  # GET /api/v1/users/:id
  def show
    authorize @user
    render json: {
      status: { code: 200, message: 'User retrieved successfully.' },
      data: UserSerializer.new(@user).serializable_hash[:data][:attributes]
    }
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    authorize @user
    if @user.update(user_params)
      render json: {
        status: { code: 200, message: 'User updated successfully.' },
        data: UserSerializer.new(@user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to update user.' },
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    authorize @user
    @user.destroy
    render json: {
      status: { code: 200, message: 'User deleted successfully.' }
    }
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'User not found.' },
      errors: ['User not found']
    }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end

  def user_data_params
    params.require(:user).permit(:email)
  end

  def generate_data_export(user)
    {
      export_generated_at: Time.current.iso8601,
      user_id: user.id,
      profile: {
        id: user.id,
        email: user.email,
        role: user.role,
        created_at: user.created_at.iso8601,
        updated_at: user.updated_at.iso8601,
        consent_given_at: user.consent_given_at&.iso8601,
        consent_withdrawn_at: user.consent_withdrawn_at&.iso8601,
        consent_version: user.consent_version
      },
      kyc: user.kyc ? {
        id: user.kyc.id,
        status: user.kyc.status,
        created_at: user.kyc.created_at.iso8601,
        updated_at: user.kyc.updated_at.iso8601,
        # Note: Sensitive KYC data is not included in export for security
        documents_count: user.kyc.documents.count
      } : nil,
      campaigns: user.campaigns.map do |campaign|
        {
          id: campaign.id,
          title: campaign.title,
          sector: campaign.sector,
          goal_amount: campaign.goal_amount,
          status: campaign.status,
          created_at: campaign.created_at.iso8601,
          updated_at: campaign.updated_at.iso8601
        }
      end,
      investments: user.investments.map do |investment|
        {
          id: investment.id,
          amount: investment.amount,
          status: investment.status,
          created_at: investment.created_at.iso8601,
          updated_at: investment.updated_at.iso8601
        }
      end,
      audit_logs: TransactionLog.where(user: user).map do |log|
        {
          id: log.id,
          action: log.action,
          record_type: log.record_type,
          record_id: log.record_id,
          details: log.details,
          ip_address: log.ip_address,
          created_at: log.created_at.iso8601
        }
      end
    }
  end

  def create_export_file(export_data, user)
    # Create JSON export
    json_content = JSON.pretty_generate(export_data)
    
    # Create file with timestamp
    filename = "user_data_export_#{user.id}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
    
    # Create blob and attach to user
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(json_content),
      filename: filename,
      content_type: 'application/json'
    )
    
    # Store reference (you might want to create a separate model for this)
    Rails.cache.write("data_export:#{user.id}:#{blob.id}", {
      user_id: user.id,
      created_at: Time.current,
      expires_at: 24.hours.from_now
    }, expires_in: 24.hours)
    
    blob
  end
end 