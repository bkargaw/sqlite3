require_relative 'questions_database.rb'
require 'byebug'
require_relative 'facebook.rb'

class Users < FaceBook
  attr_accessor :id, :fname, :lname

  def self.all
    super('users')
  end

  def self.find_by_id(id)
    super('users', id)
  end

  def self.find_by_name(fname, lname)
    users = QuestionsDBConnection.instance.execute(<<-SQL, fname , lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname like ? and lname like ?
    SQL
    return nil if users.empty?

    Users.new(users.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollows.followers_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    count_like_per_q = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
       count(questions.id) AS count
      FROM
      question_like likes
      Join questions on questions.id = likes.questions_id
      Join users on users.id = likes.user_id
      WHERE
        questions.user_id = ?
      GROUP BY
        questions.id
      SQL
      p count_like_per_q

      return 0 if count_like_per_q.empty?
      total = 0
      count_like_per_q.each do |hash|
        total += hash.values.first
      end
      total/ count_like_per_q.count
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @fname ,@lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @fname , @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end
end
