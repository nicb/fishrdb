#
# $Id: tape_box_mark.rb 541 2010-09-07 06:08:21Z nicb $
#

#require 'search_engine'

class TapeBoxMark < ActiveRecord::Base

  attr_accessor :css_style_handler

  belongs_to :tape_box_marker_collection
  belongs_to :name

  validates_presence_of :text, :marker, :tape_box_marker_collection_id

  def initialize(pars)
    @css_style_handler = CssStyleHandler.new
    super(pars)
  end

  def full_calligraphy_display
    n = name && name.valid? ? name.to_s : '??'
    r = reliability ? '' : '??'
    n_r = n == '??' ? n : n + r
    mods = (modifiers && !modifiers.empty?) ? modifiers : nil
    result = [marker, mods, n_r].compact.join(', ')
    return result
  end

  def marker=(v)
    css_color_attr(v)
    write_attribute(:marker, v)
  end

  def modifiers=(v)
    v = '' unless v
    css_modifiers_attr(v)
    write_attribute(:modifiers, v)
  end

private

  def css_color_attr(a)
    color_found = nil
    COLOR_TABLE.each do
      |k, v|
      if a =~ /#{k}/
        color_found = css_style_handler.add_qualifier('color', v)
        break
      end
    end
    css_style_handler.add_qualifier('color', 'black') unless color_found
    save_css_style
  end

  def css_modifiers_attr(a)
    a_array = a.split(/\s+/)
    a_array.each do
      |attr|
	    TRANSFORM_TABLE.each do
	      |k, v|
        if attr =~ /#{k}/
          css_style_handler.add_qualifier(v[:qualifier], v[:value])
          break
        end
	    end
    end
	  save_css_style
  end

  def save_css_style
    write_attribute(:css_style, css_style_handler.display)
  end

  def css_style=(value)
    write_attribute(:css_style, value)
  end

  class CssStyleHandler

    attr_accessor :qualifiers

    def initialize
      @qualifiers = {}
    end

    def add_qualifier(q, v)
      return q == 'color' ? add_color_qualifier(v) : add_generic_qualifier(q, v)
    end

    def display
      elements = []
      qualifiers.keys.sort.each do
        |k|
        elements << ("#{k}: " + qualifiers[k].join(' '))
      end
      result = 'style="' + elements.join('; ') + ';"'
      return result
    end

  private

    def add_generic_qualifier(q, v)
      qualifiers[q] = [] unless qualifiers[q]
      qualifiers[q] << v         # accumulation
    end

    def add_color_qualifier(v)
      qualifiers['color'] = [ v ] # exclusive addition
    end

  end

  TRANSFORM_TABLE =
  {
    'erchiat'    => { :qualifier => 'border-style', :value => 'solid' },
    'tichett'    => { :qualifier => 'border-style', :value => 'solid' },
    'ncorniciat' => { :qualifier => 'border-style', :value => 'solid' },
    'ottolineat' => { :qualifier => 'text-decoration', :value => 'underline' },
    'ancellat'   => { :qualifier => 'text-decoration', :value => 'line-through' },
    'arrat'      => { :qualifier => 'text-decoration', :value => 'line-through' },
  }

  COLOR_TABLE =
  {
    '[Bb]lu' => 'blue',
    '[Rr]oss[oa]' => 'red',
    '[Vv]erde' => 'green',
    '[Tt]urchese' => 'cyan',
    '[Bb]ordeau' => 'Crimson',
    '[Vv]iola' => 'purple',
    '[Nn]er[oa]' => 'black',
  }

end
