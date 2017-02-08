require_relative 'questions_database.rb'
require_relative 'users.rb'
require_relative 'facebook.rb'

class Replies < FaceBook
    attr_accessor :id, :replies_id, :user_id, :body, :questions_id

  def self.find_by_user_id(id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    raise "No user #{id} in our replies" if replies.empty?

    replies.map{ |reply| Replies.new(reply) }

  end

  def self.find_by_question_id(id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        questions_id = ?
    SQL
    raise "No user #{id} in our replies" if replies.empty?

    replies.map{ |reply| Replies.new(reply) }

  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @replies_id = options['replies_id']
    @user_id = options['user_id']
    @questions_id = options['questions_id']
  end

  def author
    Users.find_by_id(@user_id)
  end

  def question
    Questions.find_by_id(@question_id)
  end

  def parent_reply
    Replies.find_by_id(@replies_id)
  end

  def child_replies
    replies = QuestionsDBConnection.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies_id = ?
    SQL
    raise "No Child replies" if replies.empty?

    replies.map { |reply| Replies.new(reply)}
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def create
    QuestionsDBConnection.instance.execute(<<-SQL, @body ,@replies_id , @user_id, @questions_id)
      INSERT INTO
        replies (body, replies_id , user_id, questions_id)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @body ,@replies_id , @user_id, @questions_id, @id)
      UPDATE
        replies
      SET
        body = ?, replies_id = ?, user_id = ?, questions_id = ?
      WHERE
        id = ?
    SQL
  end

end
