sub Main()
    m = {}

    print "==== Application Start ===="

    ' Create screen and message port
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.Show()

    ' Create roInput object for handling input events
    m.input = CreateObject("roInput")
    m.input.SetMessagePort(m.port)

    print "==== Roku Input Support Enabled ===="

    ' Main message loop
    while true
        msg = wait(0, m.port)
        msgType = type(msg)

        ' Handle screen events 
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                exit while
            end if
        ' Handle input events
        else if msgType = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                print "==== Received Input Event ===="
                print "Input Data: "; FormatJSON(info)

                ' Process input action
                if info.DoesExist("action")
                    action = info.action
                    print "Processing action: "; action

                    ' Re-check if video node is initialized and valid
                    if m.video = invalid
                        print "==== ERROR: Video node is invalid when processing input action. Attempting to re-fetch the video node."
                        m.video = scene.findNode("video") ' Attempt to re-fetch the video node
                        
                        ' Retry up to 2 more times with a small delay
                        for i = 1 to 2
                            if m.video <> invalid
                                print "==== Video node found after retry. Proceeding with action."
                                exit for
                            else
                                print "==== Retry " + str(i) + " failed, waiting for video node to initialize..."
                                sleep(500) ' Wait 500ms before retry
                                m.video = scene.findNode("video") ' Retry fetching the video node
                            end if
                        next
                    end if

                    ' Process action if video node is valid
                    if m.video <> invalid
                        if action = "start" or action = "play"
                            print "==== Starting video playback ===="
                            m.video.control = "play"
                        else if action = "stop" or action = "pause"
                            print "==== Stopping video playback ===="
                            m.video.control = "stop"
                        else if action = "resume"
                            print "==== Resuming video playback ===="
                            m.video.control = "play"
                        else if action = "back"
                            print "==== Back action triggered ===="
                            ' Perform cleanup before exit
                            if m.video <> invalid
                                m.video.control = "stop"
                                print "==== Stopping video before exit ===="
                            end if

                            ' Close screen gracefully
                            screen.Close()
                            print "==== Closing the screen gracefully and exiting."
                            exit while
                        else if action = "select" or action = "ok"
                            print "==== Select/OK action triggered ===="
                            ' Toggle video playback on select/ok
                            if m.video.control = "play"
                                print "==== Pausing video ===="
                                m.video.control = "stop"
                            else
                                print "==== Playing video ===="
                                m.video.control = "play"
                            end if
                        else if action = "up" or action = "down" or action = "left" or action = "right"
                            print "==== Navigation action triggered: "; action
                        else if action = "home"
                            print "==== Home action triggered ===="
                            ' Handle the Home button action

                            ' Cleanup actions before going to the home screen
                            if m.video <> invalid
                                m.video.control = "stop"  ' Stop any video playback before going home
                                print "==== Stopping video before going to Home."
                            end if

                            ' Close the screen gracefully
                            screen.Close()
                            print "==== Navigating to Home screen."
                            exit while
                        else
                            print "==== Unknown action: "; action
                        end if
                    else
                        print "==== ERROR: Video node is still invalid after retry. Cannot perform action."
                    end if
                end if
                
                ' Handle any custom "input" command
                if info.DoesExist("input")
                    ProcessCustomInput(info, scene)
                end if
            end if
        end if
    end while
end sub

' Handle custom input commands
sub ProcessCustomInput(inputData as Object, scene as Object)
    if inputData = invalid or scene = invalid then return
    
    print "==== Processing custom input ===="
end sub

