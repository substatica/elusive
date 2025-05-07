-- elusive

function init()
  height = 63
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
      softcut.pre_level(v, .75)
      softcut.level_slew_time(v,0.25)
      softcut.level_input_cut(1, v, 1.0)
      softcut.level_input_cut(2, v, 1.0)
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
      softcut.position(v, 1)
      softcut.enable(v, 1)
  
      softcut.filter_dry(v, 0.125)
      softcut.filter_fc(v, 1200)
      softcut.filter_lp(v, 0)
      softcut.filter_bp(v, 1)
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
              if y < 64 then
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
      screen.move(60,60)
      screen.text_right("c:"..current_wave.."a:"..active_waves..'l:'..amp[current_wave].."r:"  ..freq[current_wave])
  end
  
  draw_spray()
  draw_wind()
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

-- spray
spray_amount = 10

function init_spray()
xs,ys,vsy,vsx = {},{},{},{}

xstart = math.random(127)

for i=1,spray_amount do
  xs[i] = xstart+math.random(10)-5
  ys[i] = 62-math.random(5)
  vsy[i] = math.random(3)-4
  vsx[i] = math.random(2)-4
end
gravity = .1

light = 15
end

init_spray()

function draw_spray()
screen.level(15)
done = true

for i=1,spray_amount do
  if ys[i] < 63 then
    screen.pixel(xs[i],ys[i])
    --screen.move(xs[i],ys[i])

    if ys[i] < 62 then
      done = false
    end
  
    xs[i] = (xs[i] + (vsx[i]*math.random(9,11)/10)) % 256
    ys[i] = (ys[i] + (vsy[i]*math.random(9,11)/10)) % 128
    vsy[i] = vsy[i] + gravity
    
    --screen.line_rel(vsx[i],vsy[i])
    --screen.stroke()
  end
end
screen.fill()

if done then
  init_spray()
end
end

-- wind (values and draw function)
xw,yw = {},{}
for i=1,16 do
xw[i] = math.random(256)
yw[i] = math.random(128)
end
vx,vy = math.random(10), math.random(10)
ax,ay = 0,0

function draw_wind()
screen.level(15)

for i=1,16 do
  if yw[i] < 63 and yw[i]+vy < 63 then
    screen.move(xw[i],yw[i])
    screen.line(xw[i]+vx,yw[i]+vy)
    screen.stroke()
  end
  xw[i] = (xw[i] + (vx*math.random(5,11)/10)) % 256
  yw[i] = (yw[i] + (vy*math.random(9,11)/10)) % 128
end
-- drop length
vx = math.cos(ax)*3
vy = math.abs(math.cos(ay)*4)

ax = ax+0.01
ay = ay+0.004

end
