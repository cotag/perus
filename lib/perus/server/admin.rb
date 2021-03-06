module Perus::Server
    module Admin
        def admin(type, redirect_to_record = false)
            plural   = type.to_s.pluralize
            singular = plural.singularize
            title    = singular.titleize
            klass    = title

            class_eval "
                use Sinatra.new {
                    helpers Helpers

                    before do
                        @singular = '#{singular}'
                        @plural = '#{plural}'
                        @title = '#{title}'
                        load_site_information
                    end

                    # list
                    get '/admin/#{plural}' do
                        protected!
                        @records = #{klass}.dataset.order_by(:name).all
                        erb :'admin/index'
                    end

                    # new form
                    get '/admin/#{plural}/new' do
                        protected!
                        @record = #{klass}.new
                        @form = Form.new(@record)
                        erb :'admin/new'
                    end

                    # create
                    post '/admin/#{plural}' do
                        protected!
                        @record = #{klass}.new(params[:record])
                        if @record.valid?
                            begin
                                @record.save
                                if #{redirect_to_record}
                                    redirect url_prefix + 'admin/#{plural}/' + @record.id.to_s
                                else
                                    redirect url_prefix + 'admin/#{plural}'
                                end
                                return
                            rescue
                            end
                        end

                        @form = Form.new(@record)
                        erb :'admin/new'
                    end

                    # edit
                    get '/admin/#{plural}/:id' do
                        protected!
                        @record = #{klass}.with_pk!(params['id'])
                        @form = Form.new(@record)
                        erb :'admin/edit'
                    end

                    # update
                    put '/admin/#{plural}/:id' do
                        protected!
                        @record = #{klass}.with_pk!(params['id'])
                        if @record.valid?
                            begin
                                @record.update(params[:record])
                                redirect url_prefix + 'admin/#{plural}'
                                return
                            rescue
                            end
                        end
                        
                        @form = Form.new(@record)
                        erb :'admin/edit'
                    end

                    # delete
                    delete '/admin/#{plural}/:id' do
                        protected!
                        @record = #{klass}.with_pk!(params['id'])
                        @record.destroy
                        redirect url_prefix + 'admin/#{plural}'
                    end
                }
            "
        end
    end
end
