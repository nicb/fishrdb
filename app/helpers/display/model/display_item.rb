#
# $Id: display_item.rb 389 2009-04-27 00:48:40Z nicb $
#

class DisplayItem
	attr_reader	:display_method, :display_condition, :tag, :extra

	def initialize(dm, tag, dc = :display_always)
		@display_method = dm
		@tag = tag
		@display_condition = dc
	end

protected

	def calc_valign
		return (@tag.size > 11 or !@extra.blank?) ? "bottom" : "top"
	end

  def sub_display_template(obj, user, &block)
		result = ""

		if user and obj.send(@display_condition, user)
			tbd = obj.send(@display_method)
			tbd = tbd.blank? ? "" : tbd
			#
			# do not display empty fields to end users
			#
			if !tbd.to_s.empty? || !user.end_user?
        result = yield(tbd)
			end
		end

    return result
  end

public

	def display_template(obj, user, num_field_not_used)

    result = sub_display_template(obj, user) do
      |tbd|
			%{<tr valign=\"#{self.calc_valign}\"><td class=\"record_item_tag\">#{@tag}:</td><td class=\"record_item_content\">#{tbd}</td></tr>\n}
    end
		
		return result	
	end

end

class DisplayArItem < DisplayItem

protected

  def generic_ar_display_template(obj, user, num_field, ar_form)
    ar_type = @display_method.to_s.sub(/^display_/,'').singularize.camelize
    ar_id = obj.read_attribute('id') ? obj.read_attribute('id') : 'nil'
    ar_extra = %{
    <%= link_to_remote(image_tag('fishrdb/add_16.png', :border => 0,
        :size => '14x14', :alt => 'Aggiungi', :title => 'Aggiungi'),
        :update => 'ar_form_#{num_field}',
        :url => { :action => '#{ar_form}', :id => #{ar_id}, :type => #{ar_type} }) -%>
    }

    result = sub_display_template(obj, user) do
      |tbd|
      disp_extra = user.staff? ? ar_extra : ''
			%{<tr valign=\"#{self.calc_valign}\">
          <td>#{disp_extra} #{@tag}:</td>
          <td>#{tbd}<div id=\"ar_form_#{num_field}\"></div></td>
      </tr>}
    end
		
		return result	
  end


public

  def display_template(obj, user, num_field)
    return generic_ar_display_template(obj, user, num_field, 'ar_form')
  end

end

class DisplayArPersonNameItem < DisplayArItem

  def display_template(obj, user, num_field)
    return generic_ar_display_template(obj, user, num_field, 'ar_pn_form')
  end

end

class SeparatorItem < DisplayItem
	def initialize
		super(:display_nothing, "", :display_always)
	end

	def display_template(tag_not_used, display_method_not_used, num_field_not_used)
		return %{<tr class=\"display_separator\" style=\"height: 15px;\"></tr>}
	end

end
