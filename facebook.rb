require 'sqlite3'
require 'singleton'

class FaceBook

  def self.all(table)
    QuestionsDBConnection.instance.execute(<<-SQL,table)
      SELECT
        *
      FROM
        ?
    SQL
  end

  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    raise "#{id} not in our questions" if question.empty?

    Questions.new(question.first)
  end


end
