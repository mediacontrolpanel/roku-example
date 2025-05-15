sub Init()
    print ">>> Initializing MainScene"

    ' Find the existing Video node from the XML
    m.video = m.top.findNode("video")

    ' Create and populate the ContentNode
    videoContent = CreateObject("roSGNode", "ContentNode")
    videoContent.streamFormat = "hls"
    videoContent.url = "https://cdn.mycloudstream.io/hls/live/broadcast/viducc7f/index.m3u8"
    videoContent.title = "Test Stream"

    ' Set the video node content
    m.video.content = videoContent

    ' Start playing the video
    m.video.control = "play"

    print ">>> Video started"
end sub

