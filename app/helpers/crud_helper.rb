#
# $Id: crud_helper.rb 484 2010-04-04 02:30:17Z nicb $
#

module CrudHelper

private

  def create_error_message(method_name, doc)
#   result = caller[0][caller[0].rindex('/')+1..-1] + ' ' + $!
    result = doc ? doc.errors.full_messages : "unknown error"
    classname = doc ? doc.class.name : "unknown class"
    record_name = doc ? doc.name : "unknown name"
		logger.info("#{method_name} EXCEPTION raised: record_name: #{classname}(#{record_name}), msg: #{result}")
    return result
  end

public

	def create
    record_name = params['doc']['name']
    klass = params['doc']['type'].constantize
    first_doc = klass.create_from_form(params['doc'], session)
    if first_doc
      reset_page_number
			  redirect_to_doc(first_doc, nil, params)
    else
			  rescue_redirect("Creazione di #{klass.name}(\"#{record_name}\") fallito")
    end
	end

	def update
		attrs = params['doc']
    record_name = attrs['name']
		found_doc = Document.find(attrs[:id])
	  doc = found_doc.update_from_form(attrs)
	  raise ActiveRecord::RecordNotSaved unless doc
		redirect_to_doc(doc, nil, params)
	end

	def multiple_update
		items = params['doc']
		id_to_render = params[:id]
		items.each do
			|k, v|
			doc = Document.find(k.to_i)
			attrs = { :organico_score => v }
			update_doc(doc, attrs)
		end
		redirect_to_doc(id_to_render, nil, params)
	end

	def delete
		begin
      doc = Document.find(params[:id])
      doc.delete_from_form
		  redirect_to_doc(doc.parent, nil, params)
		rescue
			rescue_redirect("Cancellazione del Record \"#{params[:id]}\" fallita (#{$!}).")
		end
	end

protected

	def get_new_object(current, classname, parent, dl_pos, creator)
    result = nil
    dl_pos = dl_pos > DescriptionLevel.last.position ? DescriptionLevel.last.position : dl_pos
		new_class = classname.constantize
		result = new_class.new_for_form(:description_level_position => dl_pos, :parent_id => parent.id,
                           :creator_id => creator.id,
                           :container_type => ContainerType.default_container_type,
                           :public_access => true, :public_visibility => parent.public_visibility)
		return result
	end

protected

	def render_new_child_or_sibling(current, parent, dl_pos, params, new_pos)
    classname = params['classname'].blank? ? 'Folder' : params['classname']
    @page = params[:page]
		form_object = get_new_object(current, classname, parent, dl_pos, session['user'])
    form_object.position = new_pos if new_pos
    #@form_object.position = new_pos if new_pos
    klass = classname.constantize
    yield(form_object) if block_given?
		template = klass.new_form
		render(:partial => template, :object => form_object, :layout => false, :page => @page)
	end

public

	def new_child_or_sibling(current, parent, dl_pos, params, new_pos=nil)
    render_new_child_or_sibling(current, parent, dl_pos, params, new_pos)
  end

	def new_child
    logger.info("======> new_child(#{params.inspect})")
		current = Document.find(params[:id])
    # childs must reset the page number, otherwise they will not appear on the
    # side bar
    params[:page] = 1
		new_child_or_sibling(current, current, current.description_level.position + 1,
			params)
	end

	def new_sibling
logger.info("======> new_sibling(#{params.inspect})")
		current = Document.find(params[:id])
    # siblings must set the page number, because they will appear
    # next to their brothers
    params[:page] = current.my_page(per_page)
		new_child_or_sibling(current, current.parent, current.description_level.position,
			params, params[:position].to_i+1)
	end

	def edit
		doc = Document.find(params[:id])
    @page = page_number(doc)
    klass = doc.read_attribute('type').constantize
    doc = klass.find(params[:id])
		template = klass.edit_form
		render(:partial => template, :object => doc, :layout => false)
	end

  def cancel
#   params[:page] = page_number(last_visited)
		redirect_to_doc(nil, nil, params)
 	end

private

  def button_selector
    unless params.has_key?('cancel')
      if params[:doc][:id].blank?
        create
      else
        update
      end
    else
      cancel
    end
  end

public

  def create_or_update_form
    begin
      button_selector
	  rescue
			rescue_redirect("Creazione/Aggiornamento del nodo falliti (#{$!})")
		end
  end
end
