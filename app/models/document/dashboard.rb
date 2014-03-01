#
# $Id$
#

module DocumentParts

  module Dashboard

    DASHBOARD_PATH = 'doc/dashboard'

    def sibling_button(page)
      return sibling_or_child_button('sibling', 'Nuova Sorella', 'add_sibling_16', 'new_sibling', page, 'single') 
    end

    def child_button(page)
      return sibling_or_child_button('children', 'Nuova Figlia', 'add_child_16', 'new_child', page, 'icon_only')
    end

    def edit_button(page)
      return editable_filter('Modifica', 'edit_16', 'edit', page) { 'single' }
    end

  private

    def sibling_or_child_button(kind, label, icon, method, page, default_result)
      meth = "allowed_#{kind}_classes"
      return editable_filter(label, icon, method, page, kind) do
        result = default_result
        temp = send(meth)
        if temp
          result = temp.is_a?(Array) && temp.size > 1 ? 'multiple' : 'single'
        end
        result
      end
    end

    def editable_filter(label, icon, method, page, kind = nil)
      kind = kind ? kind : 'sibling'
      unless self.class.editable?
        partial = 'icon_only'
      else
        partial = yield
      end
      partial = DASHBOARD_PATH + '/' + partial
      result = { :partial => partial, :object => self, :locals => { :label => label, :icon => icon, :method => method, :page => page, :kind => kind } }
      return result
    end

  end

end
