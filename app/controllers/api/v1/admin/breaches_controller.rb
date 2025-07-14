class Api::V1::Admin::BreachesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breach, only: [:show, :update, :resolve, :mark_false_positive]

  # GET /api/v1/admin/breaches
  def index
    authorize Breach
    @breaches = policy_scope(Breach)
                  .includes(:user)
                  .order(detected_at: :desc)
                  .page(params[:page])
                  .per(params[:per_page] || 20)

    render json: {
      status: { code: 200, message: 'Breaches retrieved successfully.' },
      data: {
        breaches: @breaches.map { |breach| BreachSerializer.new(breach).serializable_hash[:data][:attributes] },
        pagination: {
          current_page: @breaches.current_page,
          total_pages: @breaches.total_pages,
          total_count: @breaches.total_count
        }
      }
    }
  end

  # GET /api/v1/admin/breaches/:id
  def show
    authorize @breach
    render json: {
      status: { code: 200, message: 'Breach details retrieved successfully.' },
      data: BreachSerializer.new(@breach).serializable_hash[:data][:attributes]
    }
  end

  # PATCH/PUT /api/v1/admin/breaches/:id
  def update
    authorize @breach
    if @breach.update(breach_params)
      render json: {
        status: { code: 200, message: 'Breach updated successfully.' },
        data: BreachSerializer.new(@breach).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: 'Failed to update breach.' },
        errors: @breach.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/admin/breaches/:id/resolve
  def resolve
    authorize @breach
    @breach.resolve!
    render json: {
      status: { code: 200, message: 'Breach resolved successfully.' },
      data: BreachSerializer.new(@breach).serializable_hash[:data][:attributes]
    }
  end

  # POST /api/v1/admin/breaches/:id/mark_false_positive
  def mark_false_positive
    authorize @breach
    @breach.mark_false_positive!
    render json: {
      status: { code: 200, message: 'Breach marked as false positive.' },
      data: BreachSerializer.new(@breach).serializable_hash[:data][:attributes]
    }
  end

  # GET /api/v1/admin/breaches/summary
  def summary
    authorize Breach
    @breaches = policy_scope(Breach)
    
    render json: {
      status: { code: 200, message: 'Breach summary retrieved successfully.' },
      data: {
        total_breaches: @breaches.count,
        open_breaches: @breaches.open.count,
        critical_breaches: @breaches.critical.count,
        recent_breaches: @breaches.recent.count,
        by_type: @breaches.group(:breach_type).count,
        by_severity: @breaches.group(:severity).count,
        by_status: @breaches.group(:status).count
      }
    }
  end

  # POST /api/v1/admin/breaches/test
  def test_breach_detection
    authorize Breach
    
    # Create a test breach for demonstration
    test_breach = Breach.create!(
      breach_type: 'suspicious_activity',
      severity: 'medium',
      description: 'Test breach for demonstration purposes',
      detected_at: Time.current,
      metadata: { test: true, created_by: current_user.id }
    )
    
    render json: {
      status: { code: 200, message: 'Test breach created successfully.' },
      data: BreachSerializer.new(test_breach).serializable_hash[:data][:attributes]
    }
  end

  private

  def set_breach
    @breach = Breach.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: { code: 404, message: 'Breach not found.' },
      errors: ['Breach not found']
    }, status: :not_found
  end

  def breach_params
    params.require(:breach).permit(:status, :description, :metadata)
  end
end 