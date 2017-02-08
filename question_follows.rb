require_relative 'questions_database.rb'
require_relative 'facebook.rb'

class QuestionFollows < FaceBook
  attr_accessor :id, :user_id, :questions_id

  def self.all
    super('question_follows')
  end

  def self.find_by_id(id)
    super('question_follows', id)
  end

  def self.followers_for_question_id(question_id)
    users_follow = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_follows follow
    Join users on users.id = follow.user_id
    Join questions on questions.id = follow.questions_id
    WHERE
      questions.id = ?
    SQL
    raise "#{id} not in question follows" if users_follow.empty?
    p users_follow
    users_follow.map {|user| Users.new(user) }
  end

  def self.followers_for_user_id(user_id)
    questions_follow = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.user_id, questions.body, questions.title
    FROM
      question_follows follow
    Join users on users.id = follow.user_id
    Join questions on questions.id = follow.questions_id
    WHERE
      users.id = ?
    SQL
    raise "#{id} not in question follows" if questions_follow.empty?

    questions_follow.map {|question| Questions.new(question) }
  end

  def self.most_followed_questions(n)
    questions_follow = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      questions.id, questions.user_id, questions.body, questions.title, COUNT(questions.id) AS count
    FROM
    question_follows follow
    Join questions on questions.id = follow.questions_id
    GROUP BY questions.id
    ORDER BY count DESC
    LIMIT ?
    SQL

    raise "#{id} not in question follows" if questions_follow.empty?

    questions_follow.map {|question| Questions.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['questions_id']
  end



end
