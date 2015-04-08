SvgExport::Engine.routes.draw do
  root to: 'svg#create'
  match '/' => 'svg#create', via: [:post]
end
