sub Main(args = {} as Object)
    m = {}
    m.shouldExit = false  ' Flag to control app exit
    print "==== Application Start ===="
    
    ' Store launch args for later processing after scene is ready
    m.launchArgs = args
    
    ' Create screen and message port
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.Show()
    
    ' Store scene reference for deep link handling
    m.scene = scene
    
    ' Create roInput object for handling input events
    m.input = CreateObject("roInput")
    m.input.SetMessagePort(m.port)
    print "==== Roku Input Support Enabled ===="
    
    ' Get video node reference and wait for it to be ready
    m.video = scene.findNode("video")
    
    ' Wait a moment for the scene to fully initialize
    if m.video = invalid
        sleep(100)
        m.video = scene.findNode("video")
    end if
    
    ' Process launch args after scene is ready
    if m.launchArgs <> invalid and m.launchArgs.Count() > 0
        print "==== Processing launch deep link parameters ===="
        print "Launch args: "; FormatJSON(m.launchArgs)
        HandleDeepLink(m.launchArgs)
    else
        ' No launch args, start default stream
        print "==== No launch args, starting default stream ===="
        StartDefaultStream()
    end if
    
    ' Main message loop
    while true
        msg = wait(0, m.port)
        msgType = type(msg)
        
        ' Handle screen events 
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                exit while
            end if
        ' Handle input events (deep linking)
        else if msgType = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                print "==== Received Input Event ===="
                print "Input Data: "; FormatJSON(info)
                
                ' Handle deep link parameters (mediaType, contentId, etc.)
                HandleDeepLink(info)
                
                ' Process legacy input actions for backward compatibility
                if info.DoesExist("action")
                    ProcessInputAction(info.action)
                    ' Check if we should exit after processing the action
                    if m.shouldExit = true
                        print "==== Exit requested, closing screen ===="
                        screen.Close()
                        exit while
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

' Handle deep link parameters (simplified for single stream app)
sub HandleDeepLink(params as Object)
    if params = invalid then 
        StartDefaultStream()
        return
    end if
    
    print "==== Processing Deep Link ===="
    print "Deep link params: "; FormatJSON(params)
    
    ' Single stream app, just need to validate the request
    ' and start our one stream regardless of the specific parameters
    
    if params.DoesExist("mediaType") and params.DoesExist("contentId")
        mediaType = params.mediaType
        contentId = params.contentId
        
        print "==== Deep Link Request - MediaType: "; mediaType; ", ContentId: "; contentId
        
        ' Validate that the request makes sense for our live stream
        if mediaType = "live" or mediaType = "stream" or mediaType = "movie" or mediaType = "episode"
            ' All valid requests lead to our single live stream
            print "==== Valid deep link request, starting live stream"
            StartDefaultStream()
        else
            print "==== Unsupported mediaType: "; mediaType; ", starting default stream anyway"
            StartDefaultStream()
        end if
        
    else if params.DoesExist("contentId")
        ' ContentId without mediaType - still valid
        print "==== Deep Link - ContentId: "; params.contentId; ", starting live stream"
        StartDefaultStream()
        
    else if params.DoesExist("mediaType")
        ' MediaType without contentId - still valid  
        print "==== Deep Link - MediaType: "; params.mediaType; ", starting live stream"
        StartDefaultStream()
        
    else
        ' No standard parameters, but that's okay - start default content
        print "==== No deep link parameters, starting default stream"
        StartDefaultStream()
    end if
end sub

' Start your single live stream
sub StartDefaultStream()
    print "==== Starting Live Stream ===="
    
    ' Ensure we have a valid video node
    if m.video = invalid
        print "==== Video node invalid, attempting to find it ===="
        m.video = m.scene.findNode("video")
        
        ' Give it a moment if still not found
        if m.video = invalid
            sleep(200)
            m.video = m.scene.findNode("video")
        end if
    end if
    
    if m.video <> invalid
        print "==== Video node found, setting up content ===="
        
        ' Create content for your single live stream
        videoContent = CreateObject("roSGNode", "ContentNode")
        videoContent.streamFormat = "hls"
        videoContent.url = "https://cdn.mycloudstream.io/hls/live/broadcast/viducc7f/index.m3u8"
        videoContent.title = "Live Stream"
        
        ' Set content and play
        m.video.content = videoContent
        m.video.control = "play"
        print "==== Live stream content set, playback command sent ===="
        print "==== Stream URL: "; videoContent.url
    else
        print "==== ERROR: Video node still not available after retries ===="
    end if
end sub

' Process input actions (legacy support)
sub ProcessInputAction(action as String)
    print "Processing action: "; action
    
    ' Re-check if video node is initialized and valid
    if m.video = invalid
        print "==== ERROR: Video node is invalid when processing input action. Attempting to re-fetch the video node."
        m.video = m.scene.findNode("video")
        
        ' Retry up to 2 more times with a small delay
        for i = 1 to 2
            if m.video <> invalid
                print "==== Video node found after retry. Proceeding with action."
                exit for
            else
                print "==== Retry " + str(i) + " failed, waiting for video node to initialize..."
                sleep(500)
                m.video = m.scene.findNode("video")
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
            if m.video <> invalid
                m.video.control = "stop"
                print "==== Stopping video before exit ===="
            end if
            ' Signal to close the app - this will be handled in the main loop
            m.shouldExit = true
            print "==== Back action processed, signaling exit ===="
        else if action = "select" or action = "ok"
            print "==== Select/OK action triggered ===="
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
            if m.video <> invalid
                m.video.control = "stop"
                print "==== Stopping video before going to Home."
            end if
            ' Signal to close the app - this will be handled in the main loop
            m.shouldExit = true
            print "==== Home action processed, signaling exit ===="
        else
            print "==== Unknown action: "; action
        end if
    else
        print "==== ERROR: Video node is still invalid after retry. Cannot perform action."
    end if
end sub

' Handle custom input commands
sub ProcessCustomInput(inputData as Object, scene as Object)
    if inputData = invalid or scene = invalid then return
    
    print "==== Processing custom input ===="
end sub
