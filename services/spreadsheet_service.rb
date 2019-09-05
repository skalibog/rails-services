# frozen_string_literal: true

class SpreadsheetService
  def initialize(user)
    @user = user
    @session = GoogleDrive::Session.from_service_account_key(Rails.root.join("config/service_acc_creds.json"))
  end

  def call
    res = create_copy_ss
    create_perms(res.id)
    true
    rescue StandartError => e
      puts e
      false
  end

  private

  def create_copy_ss
    ss = @session.spreadsheet_by_key(ENV["SS_TEMPLATE_KEY"])
    result = ss.copy("Console Template for #{@user.email}")
    @user.tenant.spreadsheet_link = @session.spreadsheet_by_key(result.id).human_url
  end

  def create_perms(id)
    @session.drive.create_permission(id,
                                     user_permission,
                                     fields: 'id')
  end

  def user_permission
    {
      type: 'user',
      role: 'writer',
      email_address: @user.email
    }
  end
end
