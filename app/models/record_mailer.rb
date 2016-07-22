# -*- encoding : utf-8 -*-
# [Blacklight Override]
# Override this method because I want to give it access
# to our helpers in ApplicationHelper.
#
class RecordMailer < ActionMailer::Base

  add_template_helper(ApplicationHelper)

  def email_record(documents, details, url_gen_params)
    subject = I18n.t('blacklight.email.text.subject', :count => documents.length, :title => (documents.first.to_semantic_values[:title] rescue 'N/A') )

    @documents      = documents
    @message        = details[:message]
    @url_gen_params = url_gen_params

    mail(:to => details[:to],  :subject => subject)
  end

  def sms_record(documents, details, url_gen_params)
    @documents      = documents
    @url_gen_params = url_gen_params
    mail(:to => details[:to], :subject => "")
  end

end
