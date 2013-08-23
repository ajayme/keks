# encoding: utf-8

module LatexHelper
  # be able to use tag helpers when called from controller
  include ActionView::Helpers::TagHelper

  # legacy handler that removes now superfluous §-syntax
  def render_tex(mixed)
    return '' if mixed.blank?
    mixed = mixed.dup # don’t change original string
    imgs = []
    mixed.gsub!(/(§§?)([^§]+)\1/) do
      delims, content = $1, $2
      if content =~ /^\s*\\emph\{[a-z0-9\s.-]+\}\s*$/i
        imgs << "\\(#{content}\\)"
      else
        imgs << content
      end
      '§'
    end

    mixed = ERB::Util.h(mixed).gsub(/(\r\n){2,}|\n{2,}|\r{2,}/, '<br/><br/>'.html_safe)

    mixed.gsub!('§') do
      imgs.shift
    end

    content_tag(:div, mixed.html_safe, class: 'tex')
  end

  def latex_logo_large
    content_tag(:div, %|\\(\\Large\\LaTeX\\)|, class: 'tex', style: 'display: inline')
  end

  def latex_logo
    content_tag(:div, %|\\(\\LaTeX\\)|, class: 'tex', style: 'display: inline')
  end

  def short_matrix_str_to_tex(v)
    v = v.gsub("  ", '\\\\\\') # no idea why three are required.
    v = v.gsub(" ", " & ")
    "\\(\\begin{pmatrix} #{v} \\end{pmatrix}\\)"
  end

end
