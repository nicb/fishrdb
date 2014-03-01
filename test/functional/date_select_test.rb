#
# $Id: date_select_test.rb 343 2009-03-22 22:57:05Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class DocController < ApplicationController

  def test_date_select
    render(:inline => "<%= select_day(nil, {:start_year=>1800, :include_blank=>true, :end_year=>2050, :use_month_names=>['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'], :prefix => 'doc[data_dal]', :field_name => 'day'}) -%><%= select_month(nil, {:start_year=>1800, :include_blank=>true, :end_year=>2050, :use_month_names=>['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'], :prefix => 'doc[data_dal]', :field_name => 'month'}) -%><%= select_year(1988, {:start_year=>1800, :include_blank=>true, :end_year=>2050, :use_month_names=>['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'], :prefix => 'doc[data_dal]', :field_name => 'year'}) -%>")
  end

end

class DocControllerTest < ActionController::TestCase

  fixtures  :users, :documents

  def setup
    @controller = DocController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @user = User.authenticate('staffbob', 'testtest')
  end

  def count_selected_occurrences(string)
    sel = 'selected'
    sel_sz = sel.size
    sz = string.size
    ptr = 0
    result = 0
    radius = 30
    while ptr < sz do
      occurrence = string[ptr..sz].index(sel)
      if occurrence
#       puts(string[ptr-radius..ptr+radius])
        result += 1
        ptr = ptr + occurrence + sel_sz + 1
      else
        break
      end
    end
    return result
  end


  def test_date_select_options
    get(:test_date_select)
    assert_response :success
#   puts @response.body.inspect
    assert_equal 2, count_selected_occurrences(@response.body.inspect)
  end

end
