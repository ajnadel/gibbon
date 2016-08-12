require 'spec_helper'
require 'webmock/rspec'
require 'digest/md5'

describe Gibbon do
  let(:api_key) { '1234-us1' }
  let(:list_id) { 'testlist' }
  let(:email) { 'john.doe@example.com' }
  let(:second_email) { 'jane.doe@example.com' }
  let(:member_id) { Digest::MD5.hexdigest(email) }
  let(:second_member_id) { Digest::MD5.hexdigest(second_email) }

  let(:request_body) { MultiJson.dump(status: 'unsubscribed') }

  let(:expected_body) {
    {
      operations: [
        {
          method: "PUT",
          path: "/lists/#{list_id}/members/#{member_id}",
          body: request_body
        },
        {
          method: "DELETE",
          path: "/lists/#{list_id}/members/#{second_member_id}"
        },
      ]
    }
  }

  it 'supports batching request' do
    stub_request(:put, "https://apikey:1234-us1@us1.api.mailchimp.com/3.0/lists/#{list_id}/members/#{member_id}")
      .with(body: expected_body)
      .to_return(status: 200)

    Gibbon::Request.new(api_key: api_key).batch.create do |r|
      r.lists(list_id).members(member_id).upsert(body: request_body)
      r.lists(list_id).members(second_member_id).delete
    end
  end
end
