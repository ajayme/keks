# encoding: utf-8

module JsonHelper

  def json_for_answer(a, max_depth)
    {
      correct: a.correct,
      subquestion: get_subquestion_for_answer(a, max_depth),
      correctness: render_correctness(a),
      id: a.id,
      html: render_tex(a.text)
    }
  end

  def json_for_question(q, max_depth = 5)
    hints = []
    q.hints.each do |h|
      @hint = h
      hints << render_to_string(partial: '/hints/render')
    end

    answers = []


    if max_depth > 0
      key = ["json_for_question"]
      key << last_admin_or_reviewer_change
      key << q.id
      key = key.join("__")

      ans_qry = Rails.cache.fetch(key) {
        # the map forces rails to resolve
        q.answers.includes(:questions, :categories).map { |x| x }
      }
    else
      ans_qry = q.answers
    end

    ans_qry.each do |a|
      answers << json_for_answer(a, max_depth)
    end

    {
      starred:   signed_in? ? current_user.starred.include?(q) : false,
      hints:     hints,
      answers:   answers,
      matrix:    q.matrix_validate?,
      matrix_solution: q.matrix_solution,
      id:        q.id,
      html:      render_to_string(partial: '/questions/render', locals: {question: q})
    }
  end
end
