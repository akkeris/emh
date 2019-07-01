class Taas < AutomationFramework::Utilities
    include CallServices
    def register_test(diagnosticinfo )
        uri = '/v1/diagnostic'
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        $stdout.puts diagnosticinfo.to_json.to_s
        response = Faraday.new(ENV['APP_URL']).post uri, diagnosticinfo.to_json, headers
        $stdout.puts response.body.to_s
        expect(response.status).to eq 200
        response.body
    end
    def get_test_list()
        uri = '/v1/diagnostics'
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        return response.body, response.status        
    end
    def get_test_info(testname)
        uri = '/v1/diagnostic/'+testname
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri,{}, headers
        $stdout.puts response.body.to_s
        return response.body, response.status
    end
    def update_test(diagnosticinfo)
        uri = '/v1/diagnostic'
        headers={}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).patch uri, diagnosticinfo.to_json, headers
        return response.body, response.status
    end        
    def get_config(testname)
        uri = '/v1/diagnostic/'+testname
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        $stdout.puts JSON.parse(response.body)["env"]
        return JSON.parse(response.body)["env"], response.status
    end
    def delete_config_var(testname, var)
        uri = '/v1/diagnostic/'+testname+"/config/"+var
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).delete uri,{}, headers
        $stdout.puts response.body.to_s
        return response.body, response.status
    end        
    def destroy_test(testname)
        uri = '/v1/diagnostic/'+testname
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).delete uri,{}, headers
        $stdout.puts response.body.to_s
        return response.body
    end
    def add_config_var(testname, setname, varname, varvalue)
        uri = '/v1/diagnostic/'+testname+'/config'
        $stdout.puts uri
        payload={:setname => setname, :varname => varname, :varvalue => varvalue }
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
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
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).post uri,payload.to_json, headers
        $stdout.puts response.body.to_s
        response.body
    end
    def get_latest_test_time_and_status(job, jobspace)
        uri = '/v1/diagnostic/jobspace/'+jobspace+'/job/'+job+'/runs'
        $stdout.puts uri
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        latest = JSON.parse(response.body.to_s)["runs"][-1]
	parsed_time = DateTime.strptime(latest["hrtimestamp"], '%Y-%m-%dT%H:%M:%S')
        return parsed_time, latest["overallstatus"], latest["id"]
    end
    def get_run_logs(runid)
        uri = '/v1/diagnostic/logs/'+runid
        $stdout.puts uri
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers        
        return response.body.to_s, response.status
    end
    def get_run_info(runid)
        uri = '/v1/diagnostics/runs/info/'+runid
        $stdout.puts uri
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        return response.body.to_s, response.status
    end
    def get_audits(diagnosticinfo)
        uri = '/v1/diagnostic/'+diagnosticinfo["id"]+'/audits'
        $stdout.puts uri
        headers = {}
        headers["Authorization"] = "Bearer "+ENV["AUTH_TOKEN"]
        response = Faraday.new(ENV['APP_URL']).get uri, {}, headers
        return response.body.to_s, response.status
    end
   
  end

  
