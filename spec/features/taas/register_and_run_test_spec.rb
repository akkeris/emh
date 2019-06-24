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

  let("releasebody") { app.taas.trigger_via_release(diagnosticinfo["space"], diagnosticinfo["app"])}
  let(:destroybody) {app.taas.destroy_test(diagnosticinfo["job"]+"-"+diagnosticinfo["jobspace"])}
  scenario 'register, run, and get logs',
           type: 'contract', appserver: 'none', broken: false,
           development: true, staging: true, production: true do
    expect(JSON.parse(registerbody)).not_to be_empty
    $stdout.puts(JSON.parse(configsetbody))
    releasebody
    $stdout.puts Time.now.utc    
    currenttime = Time.now.utc
    foundit = false
    successid = ""
    10.times do
           sleep 6
           latesttime, overallstatus, runid  = app.taas.get_latest_test_time_and_status(diagnosticinfo["job"],diagnosticinfo["jobspace"])
           if latesttime > currenttime and overallstatus=="success" then
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

     $stdout.puts JSON.parse(destroybody).to_s
     status = JSON.parse(destroybody)["status"].to_s
     expect(status).to eq("deleted")

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

