# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'

RSpec.describe EdxCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'edX') }

  let(:edx_course_worker) { described_class.new }

  let(:course_data) do
    '<?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:course="https://www.edx.org/api/course/elements/1.0/"
    xmlns:staff="https://www.edx.org/api/staff/elements/1.0/">
        <channel>
            <title>edX.org course feed</title>
            <link>https://www.edx.org/api/v2/report/course-feed/rss</link>
            <atom:link rel="first" href="https://www.edx.org/api/v2/report/course-feed/rss"/>
            <atom:link rel="last" href="https://www.edx.org/api/v2/report/course-feed/rss?page=8"/>
            <atom:link rel="next" href="https://www.edx.org/api/v2/report/course-feed/rss?page=1"/>
            <atom:link href="https://www.edx.org/api/v2/report/course-feed/rss" rel="self" type="application/rss+xml" />
            <description>edX.org - course catalog feed</description>
            <language>en</language>
                    <item>
            <guid>https://www.edx.org/node/17751</guid>
            <title>Mobile Application Experiences Part 4: Understanding Use</title>
            <link>https://www.edx.org/course/mobile-application-experiences-part-4-mitx-21w-789-4x</link>
            <description>Want to create the next big app, grounded in the needs of real users? Mobile Application Experiences Part 4: Understanding Use will teach you Human Computer Interaction (HCI) methods to understand current behavior in the domain, and then design, develop, and deploy your new application.

This module will explore how people use your mobile application in daily life, over an extended period of time.  You will deploy and run quantitative and qualitative studies of use to understand not only what users are doing, but how and why they are using your application the way that they are.

This course is part of a five-part Mobile Application Experiences series:

21W.789.1x: Mobile Application Experiences Part 1: From a Domain to an App Idea
  21W.789.2x: Mobile Application Experiences Part 2: Mobile App Design
  21W.789.3x: Mobile Application Experiences Part 3: Building Mobile Apps
  21W.789.4x: Mobile Application Experiences Part 4: Understanding Use
  21w.789.5.x: Mobile Application Experiences Part 5: Reporting Research Findings
</description>
            <pubDate>Tue, 12 Jan 2016 11:52:58 -0500</pubDate>
            <course:id>course-v1:MITx+21W.789.4x+1T2016</course:id>
            <course:code>21W.789.4x</course:code>
            <course:created>Fri, 08 Jan 2016 10:42:58 -0500</course:created>
            <course:start>2016-04-25 00:00:00</course:start>
            <course:end>2016-05-23 00:00:00</course:end>
            <course:self_paced>0</course:self_paced>
            <course:subtitle>&lt;p&gt;Learn to create your own mobile app using HCI principles and discover how people use apps in their daily lives through user feedback and data analysis.&lt;/p&gt;
</course:subtitle>
            <course:subject>Computer Science</course:subject>
            <course:subject>Business &amp; Management</course:subject>
            <course:subject>Social Sciences</course:subject>
            <course:subject>Engineering</course:subject>
            <course:school>MITx</course:school>
            <course:instructors>
                <course:staff>
                    <staff:name>Frank Bentley</staff:name>
                    <staff:title></staff:title>
                    <staff:bio>Frank is a Principal Researcher at Yahoo in Sunnyvale, CA and a Visiting Lecturer in Comparative Media Studies at MIT. He works daily to ensure that new products are built to match actual user needs and that those products ship with designs that people can understand and enjoy. He has taught a local version of this class at MIT for the past 10 years, and will be teaching a new class Understanding Users at Stanford in 2016.</staff:bio>
                    <staff:image>https://www.edx.org/sites/default/files/person/image/mobile_bentley_x110.jpg</staff:image>

                </course:staff>
                <course:staff>
                    <staff:name>Ed Barrett</staff:name>
                    <staff:title></staff:title>
                    <staff:bio>Ed Barrett is Senior Lecturer in Comparative Media Studies and Writing at MIT and author of several books on digital media published by MIT Press. His work at MIT focuses on a range of topics including social media, digital humanities and corporate communications.</staff:bio>
                    <staff:image>https://www.edx.org/sites/default/files/person/image/mobile_barrett_x110.jpg</staff:image>

                </course:staff>
            </course:instructors>
            <course:video-youtube></course:video-youtube>
            <course:video-file></course:video-file>
            <course:image-banner>https://www.edx.org/sites/default/files/course/image/promoted/21w.789.4x-course_card-378x225.png</course:image-banner>
            <course:image-thumbnail>https://www.edx.org/sites/default/files/course/image/promoted/21w.789.4x-course_card-378x225.png</course:image-thumbnail>
            <course:verified>0</course:verified>
            <course:xseries>0</course:xseries>
            <course:highschool>0</course:highschool>
            <course:profed>0</course:profed>
            <course:effort>10-12 hours/week</course:effort>
            <course:length>4 weeks</course:length>
            <course:prerequisites>Having a working app that you have the source code for.</course:prerequisites>

        </item>
        </channel>
    </rss>'
  end
  let(:xml_course_data) { [Nokogiri::XML(course_data)] }
  let!(:free_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'nothing' }
  let!(:certificate_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'edx_verified_certificate' }
  let!(:xseries_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'edx_xseries_verified_certificate' }
  let!(:profed_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'edx_profed_certificate' }

  it 'delivers MOOCProvider' do
    expect(edx_course_worker.mooc_provider).to eq mooc_provider
  end

  it 'gets an API response' do
    expect(edx_course_worker.course_data).not_to be_nil
  end

  it 'loads new course into database' do
    expect { edx_course_worker.handle_response_data xml_course_data }.to change(Course, :count).by(1)
  end

  it 'loads course attributes into database' do
    edx_course_worker.handle_response_data xml_course_data

    xml_course = xml_course_data[0].xpath('//channel/item')
    course = Course.find_by(provider_course_id: xml_course.xpath('course:id').text, mooc_provider_id: mooc_provider.id)

    expect(course.name).to eq xml_course.xpath('title').text
    expect(course.provider_course_id).to eq xml_course.xpath('course:id').text
    expect(course.mooc_provider_id).to eq mooc_provider.id
    expect(course.url).to eq xml_course.xpath('link').text
    expect(course.start_date).to eq Time.zone.parse(xml_course.xpath('course:start').text).in_time_zone
    expect(course.end_date).to eq Time.zone.parse(xml_course.xpath('course:end').text).in_time_zone
    expect(course.provider_given_duration).to eq xml_course.xpath('course:length').text
    expect(course.requirements).to include xml_course.xpath('course:prerequisites').text
    expect(course.categories).to include xml_course.xpath('course:subject').first.text
    expect(course.description).to eq xml_course.xpath('description').text
    expect(course.language).to eq xml_course_data[0].xpath('//channel/language').text
    expect(course.course_instructors).to include xml_course.xpath('course:instructors/course:staff').first.xpath('staff:name').text
    expect(course.tracks.count).to eq 1
    expect(course.tracks[0].track_type.type_of_achievement).to eq free_course_track_type.type_of_achievement
    expect(course.tracks[0].costs).to eq 0.0
    expect(course.tracks[0].credit_points).to be_nil
  end

  it 'does not duplicate courses' do
    allow(RestClient).to receive(:get).and_return(course_data)
    edx_course_worker.load_courses
    expect { edx_course_worker.load_courses }.to change { Course.count }.by(0)
  end

  it 'assigns all instructors to course' do
    xml_course = xml_course_data[0].xpath('//channel/item')
    edx_course_worker.handle_response_data xml_course_data
    course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, xml_course.xpath('course:id').text)
    xml_course.xpath('course:instructors/course:staff').each do |staff|
      expect(course.course_instructors).to include staff.xpath('staff:name').text
    end
  end

  it 'assigns all subjects to course' do
    xml_course = xml_course_data[0].xpath('//channel/item')
    edx_course_worker.handle_response_data xml_course_data
    course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, xml_course.xpath('course:id').text)
    xml_course.xpath('course:subject').each do |subject|
      expect(course.categories).to include subject.text
    end
  end

  it 'creates a certificate course track type' do
    xml_course = xml_course_data[0].xpath('//channel/item')
    xml_course.xpath('course:verified').first.content = '1'
    edx_course_worker.handle_response_data xml_course_data
    course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, xml_course.xpath('course:id').text)
    expect(course.tracks.count).to eq 2
    course.tracks.each do |course_track|
      case course_track.track_type
        when free_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eq free_course_track_type.type_of_achievement
          expect(course_track.costs).to eq 0.0
          expect(course_track.credit_points).to be_nil
        when certificate_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eq certificate_course_track_type.type_of_achievement
          expect(course_track.costs).to be_nil
          expect(course_track.credit_points).to be_nil
      end
    end
  end

  it 'creates a xseries course track type' do
    xml_course = xml_course_data[0].xpath('//channel/item')
    xml_course.xpath('course:xseries').first.content = '1'
    edx_course_worker.handle_response_data xml_course_data
    course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, xml_course.xpath('course:id').text)
    expect(course.tracks.count).to eq 2
    course.tracks.each do |course_track|
      case course_track.track_type
        when free_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eq free_course_track_type.type_of_achievement
          expect(course_track.costs).to eq 0.0
          expect(course_track.credit_points).to be_nil
        when xseries_course_track_type then
          expect(course_track.track_type.type_of_achievement).to eq xseries_course_track_type.type_of_achievement
          expect(course_track.costs).to be_nil
          expect(course_track.credit_points).to be_nil
      end
    end
  end

  it 'creates a profed course track type' do
    xml_course = xml_course_data[0].xpath('//channel/item')
    xml_course.xpath('course:profed').first.content = '1'
    edx_course_worker.handle_response_data xml_course_data
    course = Course.get_course_by_mooc_provider_id_and_provider_course_id(mooc_provider.id, xml_course.xpath('course:id').text)
    expect(course.tracks.count).to eq 1
    expect(course.tracks[0].track_type.type_of_achievement).to eq profed_course_track_type.type_of_achievement
    expect(course.tracks[0].costs).to be_nil
    expect(course.tracks[0].credit_points).to be_nil
  end
end
