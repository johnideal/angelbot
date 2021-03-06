require 'slackbot_frd'

require_relative '../lib/confluence/page'

class PsaBot < SlackbotFrd::Bot
  PSA_PAGE_ID = 134_557_264

  def contains_trigger(message)
    message =~ /(p-?s-?a+y+|ps-?he+y+|psa!)/i
  end

  def add_callbacks(slack_connection)
    slack_connection.on_message do |user:, channel:, message:, timestamp:, thread_ts:|
      if message && user != :bot && user != 'angel' && timestamp != thread_ts && contains_trigger(message)
        SlackbotFrd::Log.info("Creating PSA for user '#{user}' in channel '#{channel}'")

        update_psa_page(
          author: user,
          created_at: Time.at(timestamp.to_f).utc.to_s,
          channel: channel,
          channel_id: slack_connection.channel_name_to_id(channel),
          ts: timestamp,
          message: message
        )

        slack_connection.send_message(
          channel: channel,
          message: 'View the above message, as well as the other Public Service Announcements, here: https://instructure.atlassian.net/wiki/spaces/ENG/pages/134557264/PSAs',
          thread_ts: thread_ts,
          username: 'PS-Hey Bot',
          avatar_emoji: ':robot-dance:'
        )
      end
    end
  end

  def update_psa_page(author:, created_at:, channel:, channel_id:, ts:, message:)
    page_api = Confluence::Page.new(
      username: $slackbotfrd_conf['jira_username'],
      password: $slackbotfrd_conf['jira_password']
    )

    page_api.prepend_content(
      page_id: PSA_PAGE_ID,
      author: author,
      created_at: created_at,
      channel: channel,
      channel_id: channel_id,
      ts: ts,
      content: message
    )
  end
end
