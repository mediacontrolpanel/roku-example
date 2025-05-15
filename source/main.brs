sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)

    scene = screen.CreateScene("MainScene")
    screen.Show()

    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed()
                exit while
            end if
        end if
    end while
end sub

