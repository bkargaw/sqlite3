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
    QuestionsDBConnection.instance.execute(<<-SQL,table)
      SELECT
        *
      FROM
        ?
    SQL
  end

  def self.find_by_id(table, id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, table, id)
      SELECT
        *
      FROM
        ?
      WHERE
        id = ?
    SQL
    raise "#{table} #{id} not in our database" if result.empty?

    make_into_instance(result.first,table)
  end

  private
  def make_into_instance(result,table)
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

end
