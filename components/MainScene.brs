sub Init()
    print "==== Initializing MainScene ===="
    
    ' Set up video playback
    m.video = m.top.findNode("video")
    
    ' Check if video node is found
    if m.video = invalid then
        print "==== ERROR: Video node not found! ===="
    else
        print "==== Video node initialized successfully ===="
        SetupVideoContent()
    end if
    
    ' Signal app launch complete
    m.top.signalBeacon("AppLaunchComplete")
end sub

sub SetupVideoContent()
    videoContent = CreateObject("roSGNode", "ContentNode")
    videoContent.streamFormat = "hls"
    videoContent.url = "https://cdn.mycloudstream.io/hls/live/broadcast/viducc7f/index.m3u8"
    videoContent.title = "MediaCP Example"
    
    if m.video <> invalid then
        m.video.content = videoContent
        m.video.control = "play"
        print "==== Video playback started ===="
    else
        print "==== ERROR: Video node is invalid! Cannot set content or start playback."
    end if
end sub

