-- elusive

function init()
    y = 32
    height = 64
    width = 128
    baseline = 40
    amp = {1,1,1,1,1,1}
    freq = {1,1,1,1,1,1}
    start = 1

    active_waves = 1
    current_wave = 1
 
    key_status = {0,0,0}

    audio.level_cut(1.0)
    audio.level_adc_cut(1)
    audio.level_eng_cut(1)

    for v = 1,6 do 
        softcut.level(v,0)
        softcut.pre_level(current_wave, 0.75)
        softcut.level_slew_time(v,0.25)
        softcut.level_input_cut(v, 1, 1.0)
        softcut.pan(v, 0.0)
    
        softcut.play(v, 1)
        softcut.rate(v, 1)
        softcut.rate_slew_time(v,0.25)
        softcut.loop_start(v, 1)
        softcut.loop_end(v, 1.5)
        softcut.loop(v, 1)
        softcut.fade_time(v, 0.1)
        softcut.rec(v, 1)
        softcut.rec_level(v, 1)
        softcut.pre_level(v, .75)
        softcut.position(v, 1)
        softcut.enable(v, 1)
    
        softcut.filter_dry(v, 0.125)
        softcut.filter_fc(v, 1200)
        softcut.filter_lp(v, 0)
        softcut.filter_bp(v, 1.0)
        softcut.filter_rq(v, 2.0)
    end
    
    softcut.level(current_wave,1)
  end
  
  function redraw()
    screen.clear()
    
    if y == baseline then
      start = 1
    end
    
    for w = 1,6 do
        screen.level(13-w*2)
        if w <= active_waves then
            if current_wave == w then
                screen.level(15)
            end
            softcut.level(w, 1)
            for x = 1,width-1 do
                amplitude = util.clamp((amp[w]-.5)*30,.1,45)
                frequency = 40-(math.abs(freq[w])*10)
                current_start = start+(w-1)*20
                y = (baseline+w*3) + amplitude * math.sin((current_start)+x/frequency)
                -- screen.pixel(x, y)
                -- screen.fill()
                
                -- filled
                if y < 63 then
                    screen.move(x,63)
                    screen.line(x,y)
                    screen.stroke()
                end
            end
        else
            softcut.level(w, 0)
        end
    end

    start=start+.1

    if active_waves > 0 then
        --screen.move(60,60)
        --screen.text_right(current_wave.."/"..active_waves..'l:'..amp[current_wave].."r:"..freq[current_wave])
    end
    screen.update()
  end

  function key(n,z)
    key_status[n] = z
    if z == 1 then
        if n == 3 then
            if active_waves < 6 then
                active_waves = active_waves + 1
                current_wave = active_waves
            end
        elseif n == 2 then
            if active_waves > 0 then
                active_waves = active_waves - 1
                current_wave = active_waves
            end
        end
    end
  end
  
  function enc(n,d)
    if key_status[1] == 1 then 
        if n == 2 then
            for x = 1,6 do
                amp[x] = util.clamp(amp[x] + d/100, .50, 1.5)
                level = amp[x]
                softcut.pre_level(x,level)
            end
        elseif n == 3 then
            for x = 1,6 do
                freq[x] = util.clamp(freq[x] + d/100, -4, 4)
                rate = freq[x]
                softcut.rate(x, rate)
            end
        end
    else 
        if n == 2 then
            amp[current_wave] = util.clamp(amp[current_wave] + d/100, .50, 1.5)
            level = amp[current_wave]
            softcut.pre_level(current_wave,level)
        elseif n == 3 then
            freq[current_wave] = util.clamp(freq[current_wave] + d/100, -4, 4)
            rate = freq[current_wave]
            softcut.rate(current_wave, rate)
        end
    end

    if n == 1 then
        current_wave = util.clamp(current_wave + d, 1, active_waves)
    end
  end
  
  -- Interval
  
  re = metro.init()
  re.time = 1.0 / 15
  re.event = function()
    redraw()
  end
  re:start()
  