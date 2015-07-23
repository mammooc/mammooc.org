# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'support/course_worker_spec_helper'

describe UdacityCourseWorker do
  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'Udacity') }

  let(:udacity_course_worker) do
    described_class.new
  end

  let(:courses_response) { '{"courses": [{"instructors": [{"bio": "David Evans is a Professor of Computer Science at the University of Virginia where he teaches computer science and leads <a href=\"http://www.jeffersonswheel.org/\" target=\"_blank\">research in computer security</a>. He is the author of an <a href=\"http://www.computingbook.org/\" target=\"_blank\">introductory computer science textbook</a> and has won Virginia\'s highest award for university faculty. He has PhD, SM, and SB degrees from MIT.", "image": "https://lh6.ggpht.com/1x-8cXA7JU8bNOy4xf1TyroDZlbI1aWDpeq2fjUcjEhEhfGyF5RBoS4yRjop22RBOfWNmtoyf67trTmcQg-6=s0#w=137&h=137", "name": "Dave Evans"}], "subtitle": "Build a Search Engine & a Social Network", "key": "cs101", "image": "https://lh5.ggpht.com/ITepKi-2pz4Q6lrLfv6QDNViEGIfxyupzgQwx1YgS4L8m3MFITBKWDpaZb_VoAP-zV3bEEoIbFY7mauj8HM=s0#w=1724&h=1060", "expected_learning": "You\'ll learn the programming language Python, and you\'ll explore foundational concepts in computer science. Most importantly, you\'ll start thinking like a software engineer by solving interesting problems (how to build a web crawler or a social network) using computer programming. \n\nThis course is a first step into the world of computer science, and whether you want to become a software engineer, or collaborate with software engineers, this course is for you. You\'ll be prepared for intermediate-level computer science classes when you\'ve mastered the concepts covered in this course.\n\n###Build a Search Engine\nThroughout this course, you\'ll build a search engine by learning about and producing key search engine components including a crawler, an index and a page rank algorithm. As you build these pieces, you\'ll be learning about and practicing computer science skills that will ready you for intermediate level computer science courses. \n\n###Build a Social Network\nAt the end of the course we will give you a set of relationships (i.e. strings of phrases like \u201cDave likes Andy, Kathleen and Kristy\u201d) and you will use your new computer science skills to organize these relationships into a social network. With your new social network, you can explore relationships and gain insight into how you fit into your own social networks.", "featured": false, "teaser_video": {"youtube_url": "https://www.youtube.com/watch?v=Pm_WAWZNbdA"}, "title": "Intro to Computer Science", "required_knowledge": "There is no prior computer programming knowledge needed for this course. Beginners are welcome!", "syllabus": "###Lesson 1: How to Get Started\n\n- Interview with Sergey Brin\n- Getting Started with Python\n- Processors\n- Grace Hopper\n- Variables\n- Strings and Numbers\n- Indexing Strings\n- String Theory\n\n###Lesson 2: How to Repeat\n\n- Introducing Procedures\n- Sum Procedure with a Return Statement\n- Equality Comparisons\n- If Statements\n- Or Function\n- Biggest Procedure\n- While Loops\n- Print Numbers\n\n###Lesson 2.5: How to Solve Problems\n\n- What are the Inputs\n- Algorithm Pseudocode\n- Optimizing\n\n###Lesson 3: How to Manage Data\n\n- Nested Lists\n- A List of Strings\n- Aliasing\n- List Operations\n- List Addition and Length\n- How Computers Store Data\n- For Loops\n- Popping Elements\n- Crawl Web\n\n### Lesson 4: Responding to Queries\n\n- Data Structures\n- Lookup\n- Building the Web Index\n- Latency\n- Bandwidth\n- Buckets of Bits\n- Protocols\n\n### Lesson 5: How Programs Run\n\n- Measuring Speed\n- Spin Loop\n- Index Size vs. Time\n- Making Lookup Faster\n- Hash Function\n- Testing Hash Functions\n- Implementing Hash Tables\n- Dictionaries\n- Modifying the Search Engine\n\n### Lesson 6: How to Have Infinite Power\n\n- Infinite Power\n- Counter\n- Recursive Definitions\n- Recursive Procedures\n- Palindromes\n- Recursive v. Iterative\n- Divide and Be Conquered \n- Ranking Web Pages\n\n### Lesson 7: Past, Present, and the Future of Computing\n\n- Past of Computing\n- Computer History Museum \n- First Hard Drive\n- Search Before Computers\n- Present of Computing\n- Slac and Big Data\n- Open Source\n- Future of Computing\n- Text Analysis\n- Energy Aware Computing\n- Computer Security\n- Quantum Computing", "new_release": false, "homepage": "https://www.udacity.com/course/intro-to-computer-science--cs101?utm_medium=referral&utm_campaign=api", "project_name": "Create and Analyze a Social Network", "full_course_available": true, "faq": "### When does the course begin?\n \nThis class is self paced. You can begin whenever you like and then follow your own pace. It\'s a good idea to set goals for yourself to make sure you stick with the course.\n\n### How long will the course be available?\n\nThis class will always be available! \n\n### How do I know if this course is for me?\n\n Take a look at the \u201cClass Summary,\u201d \u201cWhat Should I Know,\u201d and \u201cWhat Will I Learn\u201d sections above. If you want to know more, just enroll in the course and start exploring.\n\n### Can I skip individual videos? What about entire lessons?\n\n Yes! The point is for you to learn what YOU need (or want) to learn. If you already know something, feel free to skip ahead. If you ever find that you\'re confused, you can always go back and watch something that you skipped.\n\n### What are the rules on collaboration?\n\n Collaboration is a great way to learn. You should do it! The key is to use collaboration as a way to enhance learning, not as a way of sharing answers without understanding them. \n\n### Why are there so many questions?\n\n Udacity classes are a little different from traditional courses. We intersperse our video segments with interactive questions. There are many reasons for including these questions: to get you thinking, to check your understanding, for fun, etc... But really, they are there to help you learn. They are NOT there to evaluate your intelligence, so try not to let them stress you out.\n\n### What should I do while I\'m watching the videos?\n\n Learn actively! You will retain more of what you learn if you take notes, draw diagrams, make notecards, and actively try to make sense of the material.", "affiliates": [], "tracks": ["Data Science", "Web Development", "Software Engineering"], "banner_image": "https://lh5.ggpht.com/UCA7Y75zHA5jwS9o5dmeAn8TlBiTZZbFQZ3ktLaVnfgSHNELh1rquY1dbzOB6BaYyXP0UMNNazdauW_g1w=s0#w=4680&h=968", "short_summary": "Learn key computer science concepts in this introductory Python course. You\'ll learn by doing, and will build your own search engine and social network.", "slug": "intro-to-computer-science--cs101", "starter": true, "level": "beginner", "expected_duration_unit": "months", "summary": "In this introduction to computer programming course, you\'ll learn and practice key computer science concepts by building your own versions of popular web applications. You\'ll learn Python, a powerful, easy-to-learn, and widely used programming language, and you\'ll explore computer science basics, as you build your own search engine and social network.", "expected_duration": 3}]}' }
  let(:courses_json) { JSON.parse courses_response }
  let!(:free_course_track_type) { FactoryGirl.create :course_track_type, type_of_achievement: 'udacity_nothing' }
  let!(:certificate_course_track_type) { FactoryGirl.create :certificate_course_track_type, type_of_achievement: 'udacity_verified_certificate' }

  it 'delivers MOOCProvider' do
    expect(udacity_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'gets an API response' do
    expect(udacity_course_worker.course_data).to_not be_nil
  end

  it 'loads new course into database' do
    expect { udacity_course_worker.handle_response_data courses_json }.to change(Course, :count).by(1)
  end

  it 'loads course attributes into database' do
    allow(RestClient).to receive(:get).and_return(courses_response)
    udacity_course_worker.handle_response_data courses_json
    course = Course.find_by(provider_course_id: courses_json['courses'][0]['key'], mooc_provider_id: mooc_provider.id)

    expect(course.name).to eql courses_json['courses'][0]['title']
    expect(course.url).to eql courses_json['courses'][0]['homepage']
    expect(course.abstract).to eql courses_json['courses'][0]['summary']
    expect(course.language).to eql 'en'
    expect(course.course_image).not_to eql nil
    expect(course.videoId).to eql courses_json['courses'][0]['teaser_video']['youtube_url']
    expect(course.difficulty).to eql courses_json['courses'][0]['level'].capitalize

    expect(course.tracks.count).to eql 2
    expect(achievement_type? course.tracks, :udacity_nothing).to be_truthy
    expect(achievement_type? course.tracks, :udacity_verified_certificate).to be_truthy

    expect(course.provider_course_id).to eql courses_json['courses'][0]['key']
    expect(course.mooc_provider_id).to eql mooc_provider.id
    expect(course.categories).to match_array courses_json['courses'][0]['tracks']
    expect(course.requirements).to match_array [courses_json['courses'][0]['required_knowledge']]
    expect(course.description).to eql courses_json['courses'][0]['expected_learning']
    expect(course.course_instructors).to eql 'Dave Evans'
    expect(course.calculated_duration_in_days).to eql 90
    expect(course.provider_given_duration).to eql "#{courses_json['courses'][0]['expected_duration']} #{courses_json['courses'][0]['expected_duration_unit']}"
  end
end

