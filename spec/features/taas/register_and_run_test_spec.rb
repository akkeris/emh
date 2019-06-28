require 'spec_helper'

app = AutomationFramework::Application.new
appname = ENV['APPNAME']
spacename = ENV['SPACENAME']
image = ENV['IMAGE']

feature 'register a test and run it', sauce: false do
  let(:diagnosticinfo) do
    case app.env
    when 'MARU'
      { 'app'=>'hd',
        'space'=> 'tdev',
        'action'=>'release',
        'result'=>'succeeded',
        'image'=> 'murrayres/bashir:latest',
        'job'=>'hd-tdev',
        'jobspace'=>'taas',
        'pipelinename'=>'manual',
        'transitionfrom'=>'manual',
        'transitionto'=>'manual',
        'timeout'=> 60,
        'startdelay'=> 7,
        'slackchannel'=>'@murray.resinski'
      }
    end
  end
  let(:registerbody) { app.taas.register_test(diagnosticinfo) } 


  let(:configsetbody) { app.taas.add_config_var(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"], diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"]+"-cs", "APP_PATH","alwayspassui")} 

  let(:configsetbody2) { app.taas.add_config_var(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"], diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"]+"-cs", "MERP","derp")}

  let("releasebody") { app.taas.trigger_via_release(diagnosticinfo["space"], diagnosticinfo["app"])}


  let(:destroybody) {app.taas.destroy_test(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"])}


  scenario 'register test, get info, and list tests',
           type: 'contract', appserver: 'none', broken: false,
           development: true, staging: true, production: true do

    expect(JSON.parse(registerbody)).not_to be_empty

    testlist, testliststatus = app.taas.get_test_list
    expect(testliststatus).to be 200
    foundtest = false
    JSON.parse(testlist).each do |test| 
        if test["job"]==diagnosticinfo["job"] && test["jobspace"]==diagnosticinfo["jobspace"] && test["app"]==diagnosticinfo["app"] && test["space"]==diagnosticinfo["space"] && test["action"]==diagnosticinfo["action"] && test["result"]==diagnosticinfo["result"] then
           $stdout.puts "found test in list"
           foundtest=true
           break
        end
    end    
    expect(foundtest).to be true
  
    testinfo, testinfostatus = app.taas.get_test_info(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"])
    $stdout.puts testinfo
    expect(testinfostatus).to be 200
    expect(JSON.parse(testinfo)["job"]).to eq diagnosticinfo["job"]
    expect(JSON.parse(testinfo)["jobspace"]).to eq diagnosticinfo["jobspace"]
    expect(JSON.parse(testinfo)["app"]).to eq diagnosticinfo["app"]
    expect(JSON.parse(testinfo)["space"]).to eq diagnosticinfo["space"]
    expect(JSON.parse(testinfo)["image"]).to eq diagnosticinfo["image"]
    expect(JSON.parse(testinfo)["pipelinename"]).to eq diagnosticinfo["pipelinename"]
    expect(JSON.parse(testinfo)["transitionfrom"]).to eq diagnosticinfo["transitionfrom"]
    expect(JSON.parse(testinfo)["transitionto"]).to eq diagnosticinfo["transitionto"]
    expect(JSON.parse(testinfo)["timeout"]).to eq diagnosticinfo["timeout"]
    expect(JSON.parse(testinfo)["startdelay"]).to eq diagnosticinfo["startdelay"]
    expect(JSON.parse(testinfo)["slackchannel"]).to eq diagnosticinfo["slackchannel"]

  end


  scenario 'update test properties',
           type: 'contract', appserver: 'none', broken: false,
           development: true, staging: true, production: true do
    diagnosticinfo["startdelay"]=8   
    updatebody, updatestatus = app.taas.update_test(diagnosticinfo)
    expect(updatestatus).to eq 200
    testinfo, testinfostatus = app.taas.get_test_info(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"])
    $stdout.puts testinfo
    expect(testinfostatus).to be 200
    expect(JSON.parse(testinfo)["startdelay"]).to eq 8
  end

  scenario 'Set / Unset Config Vars',
           type: 'contract', appserver: 'none', broken: false,
           development: true, staging: true, production: true do
    $stdout.puts(JSON.parse(configsetbody))
    $stdout.puts(JSON.parse(configsetbody2))
    deleteconfigbody, deleteconfigstatus = app.taas.delete_config_var(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"], "MERP")
    $stdout.puts deleteconfigbody
    expect(deleteconfigstatus).to eq 200
    configbody, configstatus = app.taas.get_config(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"])
    $stdout.puts configbody.to_s
    expect(configstatus).to eq 200
    expect(configbody.to_s).to eq '[{"name"=>"APP_PATH", "value"=>"alwayspassui"}]'   
  end


  scenario 'run test, get test run info, and get logs',
           type: 'contract', appserver: 'none', broken: false,
           development: true, staging: true, production: true do
    firsttime, overallstatus, runid = app.taas.get_latest_test_time_and_status(diagnosticinfo["job"],diagnosticinfo["jobspace"])
    
    releasebody
    foundit = false
    successid = ""
    $stdout.puts firsttime
    10.times do
           sleep 6
           latesttime, overallstatus, runid  = app.taas.get_latest_test_time_and_status(diagnosticinfo["job"],diagnosticinfo["jobspace"])
           $stdout.puts latesttime
           if latesttime != firsttime and overallstatus=="success" then
               foundit = true
               successid = runid
               break
           end
    end   
     $stdout.puts "DONE"
     $stdout.puts foundit
     $stdout.puts successid
     expect(foundit).to be true
     infobody, infostatuscode = app.taas.get_run_info(successid)
     expect(infobody).not_to be_empty
     expect(infostatuscode).to eq 200

     logsbody, logsstatuscode = app.taas.get_run_logs(successid)
     $stdout.puts logsbody, logsstatuscode 
     expect(logsbody).not_to be_empty
     expect(logsstatuscode).to eq 200
 end

  scenario 'delete test',
           type: 'contract', appserver: 'none', broken: false,
           development: true, staging: true, production: true do
     $stdout.puts JSON.parse(destroybody).to_s
     status = JSON.parse(destroybody)["status"].to_s
     expect(status).to eq("deleted")
    testlist, testliststatus = app.taas.get_test_list
    expect(testliststatus).to be 200
    foundtest = false
    JSON.parse(testlist).each do |test|
        if test["job"]==diagnosticinfo["job"] && test["jobspace"]==diagnosticinfo["jobspace"] && test["app"]==diagnosticinfo["app"] && test["space"]==diagnosticinfo["space"] && test["action"]==diagnosticinfo["action"] && test["result"]==diagnosticinfo["result"] then
           $stdout.puts "found test in list"
           foundtest=true
           break
        end
    end
    expect(foundtest).to be false

  end

before(:all) do
    $stdout.puts "running reset"
    case app.env
    when 'MARU'
      JSON.parse(app.taas.destroy_test("hd-tdev-taas"))
      $stdout.puts "done with reset"
    end 
   end
end

