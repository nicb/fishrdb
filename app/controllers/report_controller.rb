#
# $Id: report_controller.rb 224 2008-06-17 04:59:38Z nicb $
#
class ReportController < ApplicationController

  def list
    @root = Document.find(params[:id])
    render(:action => 'list') 
  end

end
