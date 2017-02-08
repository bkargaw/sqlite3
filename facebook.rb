require 'sqlite3'

class FaceBook

  # TABLE_TO_CLASS = {
  #   'Questions' => Questions,
  #   'Users' => Users,
  #   'Replies' => Replies,
  #   'QuestionFollows' => QuestionFollows,
  #   'QuestionLike' => QuestionLike
  # }

  def self.all(table)
    QuestionsDBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL
  end

  def self.find_by_id(table, id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL
    raise "#{table} #{id} not in our database" if result.empty?

    make_into_instance(result.first,table)
  end

  # protected

  def self.make_into_instance(result,table)
    case table.downcase
    when 'questions'
      Questions.new(result)
    when 'users'
      Users.new(result)
    when 'replies'
      Replies.new(result)
    when 'question_follows'
      QuestionFollows.new(result)
    when 'question_like'
      QuestionLike.new(result)
    end
  end

  def save
    if @id.nil?
      create
    else
      update
    end
  end

  def create

    QuestionsDBConnection.instance.execute(<<-SQL)
      INSERT INTO
        questions(title, body, user_id)
      VALUES
        []
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
