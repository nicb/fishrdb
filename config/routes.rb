#
# $Id: routes.rb 244 2008-07-19 04:28:41Z nicb $
#
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  # allow for searching view the route
  map.connect 'search/:search_terms/:count', :controller => 'search', :action => 'index', :count => '-1' 
  
  # allow for Open Search RSS feeds searching
  map.connect 'rss/opensearch/description.xml', :controller => 'search', :action => 'description'
  map.connect 'rss/opensearch/:search_terms/:count', :controller => 'search', :action => 'rss', :count => '-1'  

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "pview", :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
