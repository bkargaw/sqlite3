require_relative 'questions_database.rb'
require_relative 'facebook.rb'

class QuestionLike < FaceBook
  attr_accessor :id, :user_id, :questions_id

  def self.all
    super('question_like')
  end

  def self.find_by_id(id)
    super('question_like', id)
  end

  def self.likers_for_question_id(question_id)
    question_like = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
      question_like likes
      Join questions on questions.id = likes.questions_id
      Join users on users.id = likes.user_id
      WHERE
        questions.id  = ?
      SQL

      raise "No likers for question #{question_id}" if question_like.empty?

      question_like.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    question_like = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        count(*) count
      FROM
      question_like likes
      Join questions on questions.id = likes.questions_id
      Join users on users.id = likes.user_id
      WHERE
        questions.id  = ?

      SQL
      raise "no likes for #{question_id}" if question_like.empty?
      question_like[0]['count']
  end

  def self.liked_questions_for_user_id(user_id)
    user_like = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.user_id, questions.body, questions.title
      FROM
      question_like likes
      Join questions on questions.id = likes.questions_id
      Join users on users.id = likes.user_id
      WHERE
        users.id  = ?
      SQL
      raise "no liked question for #{user_id}" if user_like.empty?

      user_like.map { |question| Questions.new(question) }

  end

  def self.most_liked_questions(n)
    question_like = QuestionsDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.user_id, questions.body, questions.title, COUNT(questions.id) AS count
      FROM
      question_like likes
      Join questions on questions.id = likes.questions_id
      Join users on users.id = likes.user_id
      GROUP BY
        questions.id
      ORDER BY count DESC
      LIMIT ?

      SQL
      raise "no likes" if question_like.empty?

      question_like.map { |question| Questions.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['questions_id']
  end


end
