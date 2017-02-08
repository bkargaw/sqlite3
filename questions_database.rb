require_relative 'facebook.rb'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class Questions < FaceBook
  attr_accessor :id, :title, :user_id, :body

  def self.all
    super('questions')
  end

  def self.find_by_id
    super('questions', @id)
  end

  def self.find_by_author_id(author_id)

    question = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    raise "No question by that author" if question.empty?
    # mapp array of questions
    question.map {|que| Questions.new(que)}
  end

  def initialize(options)
    @id = options['id'] #id nil if instansiated by user
    @title = options['title']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    Users.find_by_id(@user_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def most_followed(n)
    QuestionFollows.most_followed(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions(title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL,@title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ? , user_id = ?
      WHERE
        id = ?
    SQL
  end











end
