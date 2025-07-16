class DocsController < ApplicationController
  def index
    @docs = [
      { title: 'Authentication Guide', path: 'authentication', description: 'JWT authentication and API endpoints' },
      { title: 'Environment Setup', path: 'environment_setup', description: 'Configuration and environment variables' },
      { title: 'SSL Setup Guide', path: 'ssl_setup', description: 'HTTPS and SSL certificate setup' },
      { title: 'Compliance Checklist', path: 'compliance_checklist', description: 'UPDA compliance requirements' },
      { title: 'Data Protection Policy', path: 'data_protection_policy', description: 'Privacy and data protection policy' },
      { title: 'Data Retention Policy', path: 'data_retention_policy', description: 'Data retention and disposal policy' }
    ]
  end

  def show
    @doc_path = params[:doc]
    @doc_file = Rails.root.join('docs', "#{@doc_path}.md")
    
    if File.exist?(@doc_file)
      @content = File.read(@doc_file)
      @title = get_doc_title(@doc_path)
    else
      render file: "#{Rails.root}/public/404.html", status: :not_found
    end
  end

  private

  def get_doc_title(doc_path)
    titles = {
      'authentication' => 'Authentication Guide',
      'environment_setup' => 'Environment Setup Guide',
      'ssl_setup' => 'SSL/HTTPS Setup Guide',
      'compliance_checklist' => 'Compliance Checklist',
      'data_protection_policy' => 'Data Protection Policy',
      'data_retention_policy' => 'Data Retention Policy'
    }
    titles[doc_path] || 'Documentation'
  end
end 