class VisitorsController < ApplicationController
  
  def new
    @visitor = Visitor.new
  end
  
end