require 'active_support'
require 'active_support/core_ext/string'

module Server::Admin
    def admin(type)
        plural   = type.to_s.pluralize
        singular = plural.singularize
        title    = singular.titlecase
        klass    = "Server::#{title}"

        class_eval "
            use Sinatra.new {
                before do
                    @plural = '#{plural}'
                    @title = '#{title}'
                    @site_name = Server.options.site_name
                    @groups = Server::Group.all
                end

                # list
                get '/admin/#{plural}' do
                    @records = #{klass}.all
                    erb :'admin/index'
                end

                # new form
                get '/admin/#{plural}/new' do
                    @record = #{klass}.new
                    @form = Server::Form.new(@record)
                    erb :'admin/new'
                end

                # create
                post '/admin/#{plural}' do
                    @record = #{klass}.new(params[:record])
                    if @record.valid?
                        begin
                            @record.save
                            redirect to('/admin/#{plural}')
                        rescue
                        end
                    end

                    @form = Server::Form.new(@record)
                    erb :'admin/new'
                end

                # edit
                get '/admin/#{plural}/:id' do
                    @record = #{klass}.with_pk!(params['id'])
                    @form = Server::Form.new(@record)
                    erb :'admin/edit'
                end

                # update
                put '/admin/#{plural}/:id' do
                    @record = #{klass}.with_pk!(params['id'])
                    if @record.valid?
                        begin
                            @record.update(params[:record])
                            redirect to('/admin/#{plural}')
                        rescue
                        end
                    end
                    
                    @form = Server::Form.new(@record)
                    erb :'admin/edit'
                end

                # delete
                delete '/admin/#{plural}/:id' do
                    @record = #{klass}.with_pk!(params['id'])
                    @record.destroy
                    redirect to('/admin/#{plural}')
                end
            }
        "
    end
end
