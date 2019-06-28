class Taas < AutomationFramework::Utilities
    include CallServices
    def register_test(diagnosticinfo )
        uri = '/v1/diagnostic'
        headers = {}
        $stdout.puts diagnosticinfo.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).post uri, diagnosticinfo.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 200
        response.body
    end
    def get_test_list()
        uri = '/v1/diagnostics'
        headers = {}
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        return response.body, response.status        
    end
    def get_test_info(testname)
        uri = '/v1/diagnostic/'+testname
        headers = {}
        response = Faraday.new(ENV['APP_URL']).get uri,{}, headers
        $stdout.puts response.body.to_s
        return response.body, response.status
    end
    def update_test(diagnosticinfo)
        uri = '/v1/diagnostic'
        headers = {}
        response = Faraday.new(ENV['APP_URL']).patch uri, diagnosticinfo.to_json, headers
        return response.body, response.status
    end        
    def get_config(testname)
        uri = '/v1/diagnostic/'+testname
        headers = {}
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        $stdout.puts JSON.parse(response.body)["env"]
        return JSON.parse(response.body)["env"], response.status
    end
    def delete_config_var(testname, var)
        uri = '/v1/diagnostic/'+testname+"/config/"+var
        headers = {}
        response = Faraday.new(ENV['APP_URL']).delete uri,{}, headers
        $stdout.puts response.body.to_s
        return response.body, response.status
    end        
    def destroy_test(testname)
        uri = '/v1/diagnostic/'+testname
        headers = {}
        response = Faraday.new(ENV['APP_URL']).delete uri,{}, headers
        $stdout.puts response.body.to_s
        return response.body
    end
    def add_config_var(testname, setname, varname, varvalue)
        uri = '/v1/diagnostic/'+testname+'/config'
        $stdout.puts uri
        payload={:setname => setname, :varname => varname, :varvalue => varvalue }
        headers = {}
        response = Faraday.new(ENV['APP_URL']).post uri,payload.to_json, headers
        $stdout.puts response.body.to_s
        response.body
    end
    def trigger_via_release(space, app)
        uri = '/v1/releasehook'
        $stdout.puts uri
        payload={:action => 'release', :app => {:name => app}, :space => {:name => space}, :release => {:result => 'succeeded'}}
        $stdout.puts payload.to_json.to_s
        headers = {}
        response = Faraday.new(ENV['APP_URL']).post uri,payload.to_json, headers
        $stdout.puts response.body.to_s
        response.body
    end
    def get_latest_test_time_and_status(job, jobspace)
        uri = '/v1/diagnostic/jobspace/'+jobspace+'/job/'+job+'/runs'
        $stdout.puts uri
        headers = {}
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        latest = JSON.parse(response.body.to_s)["runs"][-1]
	parsed_time = DateTime.strptime(latest["hrtimestamp"], '%Y-%m-%dT%H:%M:%S')
        return parsed_time, latest["overallstatus"], latest["id"]
    end
    def get_run_logs(runid)
        uri = '/v1/diagnostic/logs/'+runid
        $stdout.puts uri
        headers = {}
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers        
        return response.body.to_s, response.status
    end
    def get_run_info(runid)
        uri = '/v1/diagnostics/runs/info/'+runid
        $stdout.puts uri
        headers = {}
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        return response.body.to_s, response.status
    end
   
=begin
    def deletespace(name, internal, stack)
        uri = '/v1/space/'+name
        headers = {}
        payload={:name => name,:internal => internal,:stack => stack }
        $stdout.puts payload.to_json.to_s
        conn = Faraday.new
        response = conn.run_request(:delete, ENV['APP_URL']+uri, payload.to_json, headers)
        $stdout.puts response.body.to_s
        response.body
    end
    def createapp(appname, appport)
        uri = '/v1/app'
        headers = {}
        payload={:appname => appname,:appport => appport }
        $stdout.puts payload.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).post uri, payload.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 201
        response.body
    end
    def deleteapp(appname)
        uri = '/v1/app/'+appname
        headers = {}
        response = Faraday.new(ENV['APP_URL']).delete uri, {}, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 200
        response.body
    end
    def addapptospace(appname, space, instances, plan)
        uri = '/v1/space/'+space+'/app/'+appname
        headers = {}
        payload={:appname => appname,:space => space,:instances=>instances,:plan=>plan }
        $stdout.puts payload.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).put uri, payload.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 201
        response.body
    end
    def deleteappfromspace(appname, space)
        uri = '/v1/space/'+space+'/app/'+appname
        headers = {}
        response = Faraday.new(ENV['APP_URL']).delete uri, {}, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 200
        response.body
    end

    def createconfigset(name, type)
        uri = '/v1/config/set'
        headers = {}
        payload={:name => name,:type => type}
        $stdout.puts payload.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).post uri, payload.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 201
        response.body
    end
    def deleteconfigset(name)
        uri = '/v1/config/set/'+name
        headers = {}
        response = Faraday.new(ENV['APP_URL']).delete uri, {}, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 200
        response.body
    end
    def addconfigvar(setname, varname, varvalue)
        
        uri = '/v1/config/set/configvar'
        headers = {}
        payload={:setname => setname,:varname => varname,:varvalue=>varvalue}
        payloadarray =[]
        payloadarray << payload
        $stdout.puts payload.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).post uri, payloadarray.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 201
        sleep 5
        response.body
    end
    def deleteconfigvar(setname, varname)
        uri = '/v1/config/set/'+setname+'/configvar/'+varname
        headers = {}
        response = Faraday.new(ENV['APP_URL']).delete uri, {}, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 200
        response.body
    end
    def deployapp(appname, space, appimage, port)
        uri = '/v1/app/deploy'
        headers = {}
        payload={:appname => appname,:space => space,:appimage=>appimage, :port=>port}
        $stdout.puts payload.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).post uri, payload.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 201
        response.body
    end
    def livecheck(url)
        uri = '/'
        headers = {}
        $stdout.puts url
        begin
          response = Faraday.new(url).get uri, {}, headers
          return response.status
        rescue => e
          $stdout.puts e.message
          return 0
        end  
        return 0
    end
=end
  end

  
