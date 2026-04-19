// screens.jsx — Home, Habit Detail, Daily Check-in screens
// Uses window.* components from tokens/icons/components/primitives

function HomeScreen({ t, state, dispatch, dayOne }) {
  if (dayOne && typeof HomeEmpty !== 'undefined') return <HomeEmpty t={t} dispatch={dispatch}/>;
  const { readiness, mood, streak } = state;
  const habits = (state.habits || []).filter(h => !h.archived);
  const done = habits.filter(h => h.checked).length;
  const total = habits.length;
  const greeting = (() => {
    const h = new Date().getHours();
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  })();

  return (
    <>
      {/* Warm header with large title */}
      <div style={{ padding: '54px 20px 4px', background: t.color.bg }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 34 }}>
          <button onClick={() => dispatch({ type: 'goto', screen: 'settings' })}
            aria-label="Settings"
            style={{
              width: 36, height: 36, borderRadius: 18, background: t.color.secondaryMuted,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              border: 'none', cursor: 'pointer', padding: 0,
              transition: 'transform 160ms cubic-bezier(0.34, 1.2, 0.64, 1)',
            }}
            onPointerDown={e => e.currentTarget.style.transform = 'scale(0.94)'}
            onPointerUp={e => e.currentTarget.style.transform = 'scale(1)'}
            onPointerLeave={e => e.currentTarget.style.transform = 'scale(1)'}>
            <span style={{ fontFamily: t.family.rounded, fontWeight: 600, color: t.color.secondary, fontSize: 14 }}>JS</span>
          </button>
          <button onClick={() => dispatch({ type: 'goto', screen: 'checkin' })}
            style={{ border: 'none', background: 'transparent', cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 4, padding: 4 }}>
            <Icon name="bell" size={22} color={t.color.textSecondary}/>
          </button>
        </div>
        <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 14, textTransform: 'none' }}>
          {new Date().toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, marginTop: 2 }}>
          {greeting}, Jess
        </div>
      </div>

      <div style={{ padding: '12px 16px 100px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* Morning check-in or readiness banner */}
        {!mood ? (
          <button onClick={() => dispatch({ type: 'goto', screen: 'checkin' })} style={{
            textAlign: 'left', padding: '14px 16px', borderRadius: t.radius.card, border: 'none',
            background: `linear-gradient(135deg, ${t.color.primaryTint}, ${t.color.surfaceCard})`,
            boxShadow: t.elev.sm, cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ width: 38, height: 38, borderRadius: 12, background: t.color.primaryMuted,
              display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="sun" size={20} color={t.color.primary}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>How are you today?</div>
              <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 1 }}>
                A quick morning check-in · under a minute
              </div>
            </div>
            <Icon name="chevronRight" size={16} color={t.color.textTertiary} strokeWidth={2}/>
          </button>
        ) : (
          <button onClick={() => dispatch({ type: 'goto', screen: 'checkin' })} style={{
            textAlign: 'left', padding: '12px 14px', borderRadius: t.radius.card, border: 'none',
            background: t.color.secondaryTint, cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: t.color.secondaryMuted,
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>
              {MOODS.find(m => m.k === mood)?.emoji}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ ...typeStyle(t.type.footnote, t.family), fontWeight: 600, color: t.color.textPrimary }}>
                Feeling {mood} · readiness {readiness}/10
              </div>
              <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>
                We tuned today to match
              </div>
            </div>
            <Icon name="chevronRight" size={14} color={t.color.textTertiary}/>
          </button>
        )}

        {/* Streak hero */}
        <StreakHero t={t}
          days={streak}
          message={streak === 0 ? "Every streak starts with one day." : `You've shown up ${streak} days in a row. Proud of you.`}/>

        {/* Today's plan */}
        <div style={{ marginTop: 4 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '0 4px 10px' }}>
            <div style={{ ...typeStyle(t.type.title3, t.family), color: t.color.textPrimary }}>Today's plan</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary }}>
                {done} of {total} done
              </div>
              <button onClick={() => dispatch({ type: 'goto', screen: 'habitNew' })}
                aria-label="Add habit"
                style={{
                  width: 28, height: 28, borderRadius: 14,
                  border: 'none', cursor: 'pointer',
                  background: t.color.primaryTint,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                <Icon name="plus" size={14} color={t.color.primary} strokeWidth={2.6}/>
              </button>
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {habits.map(h => (
              <div key={h.id} onClick={() => dispatch({ type: 'goto', screen: 'habitDetail', habitId: h.id })} style={{ cursor: 'pointer' }}>
                <HabitCard t={t}
                  title={h.title} subtitle={h.subtitle}
                  progress={h.progress} streak={h.streak}
                  checked={h.checked} category={h.category} duration={h.duration}
                  onToggle={(e) => { e?.stopPropagation?.(); dispatch({ type: 'toggle', id: h.id }); }}/>
              </div>
            ))}
          </div>
        </div>

        {/* Quote / gentle encouragement */}
        <div style={{
          marginTop: 6, padding: 18, borderRadius: t.radius.card,
          background: t.color.secondaryTint, display: 'flex', gap: 12,
        }}>
          <Icon name="leaf" size={22} color={t.color.secondary}/>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: t.family.rounded, fontSize: 16, fontWeight: 500, lineHeight: '22px', color: t.color.textPrimary, fontStyle: 'italic' }}>
              "Small, steady beats loud and sporadic."
            </div>
            <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary, marginTop: 6 }}>
              Weekly reflection · Sunday
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

function DetailScreen({ t, state, dispatch }) {
  const habit = state.habits.find(h => h.id === state.detailId) || state.habits[0];
  // 12 weeks heatmap stub
  const heat = React.useMemo(() => {
    return Array.from({ length: 84 }).map((_, i) => {
      const r = Math.sin(i * 0.73) * 0.5 + 0.5;
      if (i < 6) return 0;
      if (r > 0.8) return 1;
      if (r > 0.55) return 0.65;
      if (r > 0.35) return 0.3;
      return 0;
    });
  }, []);

  return (
    <>
      <div style={{ padding: '52px 16px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={() => dispatch({ type: 'goto', screen: 'home' })}
          style={{ display: 'flex', alignItems: 'center', gap: 2, border: 'none', background: 'transparent',
            color: t.color.primary, fontFamily: t.family.text, fontSize: 17, cursor: 'pointer', padding: 4 }}>
          <Icon name="chevronLeft" size={22} color={t.color.primary} strokeWidth={2.4}/>
          <span>Today</span>
        </button>
        <button onClick={() => dispatch({ type: 'goto', screen: 'habitEdit', habitId: habit.id })}
          style={{ border: 'none', background: 'transparent', cursor: 'pointer', padding: 4,
            fontFamily: t.family.text, fontSize: 16, color: t.color.primary, fontWeight: 500 }}>
          Edit
        </button>
      </div>

      <div style={{ padding: '8px 20px 100px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
          <div style={{ width: 28, height: 28, borderRadius: 8, background: t.color.primaryMuted,
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name={habit.icon || 'dumbbell'} size={16} color={t.color.primary}/>
          </div>
          <span style={{ ...typeStyle(t.type.caption2, t.family), textTransform: 'uppercase', color: t.color.textTertiary }}>
            {habit.category} · {habit.duration}
          </span>
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, letterSpacing: -0.8 }}>
          {habit.title}
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 4 }}>
          {habit.subtitle}
        </div>

        {/* Check-off hero */}
        <div style={{ marginTop: 22, padding: '22px 20px', borderRadius: t.radius.cardLg,
          background: habit.checked ? t.color.secondaryTint : t.color.primaryTint,
          display: 'flex', alignItems: 'center', gap: 18, boxShadow: t.elev.sm }}>
          <ProgressRing
            progress={habit.checked ? 1 : habit.progress}
            size={84} stroke={7}
            color={habit.checked ? t.color.secondary : t.color.primary}
            trackColor={habit.checked ? t.color.secondaryMuted : t.color.primaryMuted}>
            <button onClick={() => dispatch({ type: 'toggle', id: habit.id })} style={{
              width: 62, height: 62, borderRadius: 9999, border: 'none',
              background: habit.checked ? t.color.secondary : t.color.surface,
              boxShadow: t.elev.sm, cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              transition: 'all 260ms cubic-bezier(0.34, 1.2, 0.64, 1)',
            }}>
              {habit.checked
                ? <Icon name="check" size={28} color="#fff" strokeWidth={2.6}/>
                : <Icon name="plus" size={28} color={t.color.primary} strokeWidth={2.6}/>}
            </button>
          </ProgressRing>
          <div style={{ flex: 1 }}>
            <div style={{ ...typeStyle(t.type.title3, t.family), color: t.color.textPrimary }}>
              {habit.checked ? 'Done for today' : 'Ready when you are'}
            </div>
            <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 2 }}>
              {habit.checked ? 'See you tomorrow.' : `Last done ${habit.lastDone || '2 days ago'}`}
            </div>
          </div>
        </div>

        {/* Stat row */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginTop: 16 }}>
          {[
            { label: 'Streak', value: habit.streak, unit: 'days', icon: 'flame' },
            { label: 'This week', value: habit.weekDone || 3, unit: `of ${habit.weekTarget || 4}`, icon: 'calendar' },
            { label: 'All time', value: habit.allTime || 47, unit: 'done', icon: 'trophy' },
          ].map((s, i) => (
            <div key={i} style={{ padding: 12, borderRadius: t.radius.md,
              background: t.color.surfaceCard, boxShadow: t.elev.xs }}>
              <Icon name={s.icon} size={15} color={t.color.textTertiary}/>
              <div style={{ fontFamily: t.family.rounded, fontSize: 26, fontWeight: 700, color: t.color.textPrimary, marginTop: 6, letterSpacing: -0.8 }}>
                {s.value}
              </div>
              <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>
                {s.label} · {s.unit}
              </div>
            </div>
          ))}
        </div>

        {/* Start session CTA (Strength only) */}
        {habit.category === 'Strength' && !habit.checked && (
          <button onClick={() => dispatch({ type: 'goto', screen: 'logger' })}
            style={{
              marginTop: 16, width: '100%', padding: '16px 18px',
              borderRadius: t.radius.pill, border: 'none', cursor: 'pointer',
              background: t.color.primary, boxShadow: t.elev.md,
              color: t.color.onPrimary,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
              fontFamily: t.family.rounded, fontSize: 17, fontWeight: 700,
              letterSpacing: -0.2,
            }}>
            <Icon name="play" size={16} color={t.color.onPrimary} strokeWidth={2.4}/>
            Start session
            <span style={{ ...typeStyle(t.type.footnote, t.family), color: 'rgba(255,255,255,0.75)',
              fontWeight: 500, marginLeft: 4 }}>
              · {habit.duration}
            </span>
          </button>
        )}

        {/* Heatmap */}
        <div style={{ marginTop: 20, padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
            <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>Your rhythm</div>
            <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>84 days</div>
          </div>
          <Heatmap t={t} data={heat}/>
        </div>

        {/* Weekly chart */}
        <div style={{ marginTop: 16, padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>This week</div>
          <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 2, marginBottom: 16 }}>
            You're trending up, gently.
          </div>
          <WeekBars t={t}/>
        </div>
      </div>
    </>
  );
}

function WeekBars({ t }) {
  const days = ['M','T','W','T','F','S','S'];
  const values = [0.4, 0.8, 0.6, 0.9, 0.5, 0.7, 0.3];
  const today = 3;
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 10, height: 120 }}>
      {values.map((v, i) => (
        <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
          <div style={{ flex: 1, width: '100%', display: 'flex', alignItems: 'flex-end' }}>
            <div style={{ width: '100%',
              height: `${v * 100}%`, borderRadius: 8,
              background: i === today ? t.color.primary : t.color.primaryMuted,
              transition: 'height 600ms cubic-bezier(0.34, 1.2, 0.64, 1)' }}/>
          </div>
          <div style={{ fontFamily: t.family.rounded, fontSize: 12, fontWeight: 600,
            color: i === today ? t.color.primary : t.color.textTertiary }}>{days[i]}</div>
        </div>
      ))}
    </div>
  );
}

function CheckinScreen({ t, state, dispatch }) {
  const [mood, setMood] = React.useState(state.mood);
  const [readiness, setReadiness] = React.useState(state.readiness);
  const [journal, setJournal] = React.useState(state.journal);

  const save = () => {
    dispatch({ type: 'checkin', mood, readiness, journal });
    dispatch({ type: 'goto', screen: 'home' });
  };

  return (
    <>
      <div style={{ padding: '52px 16px 6px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={() => dispatch({ type: 'goto', screen: 'home' })}
          style={{ border: 'none', background: 'transparent', cursor: 'pointer',
            fontFamily: t.family.text, fontSize: 17, color: t.color.primary, padding: 4 }}>
          Cancel
        </button>
        <span style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>Check-in</span>
        <button onClick={save} disabled={!mood}
          style={{ border: 'none', background: 'transparent', cursor: mood ? 'pointer' : 'default',
            fontFamily: t.family.rounded, fontSize: 17, fontWeight: 600,
            color: mood ? t.color.primary : t.color.textTertiary, padding: 4 }}>
          Save
        </button>
      </div>

      <div style={{ padding: '8px 16px 100px' }}>
        <div style={{ ...typeStyle(t.type.title1, t.family), color: t.color.textPrimary, marginTop: 16, padding: '0 4px' }}>
          Morning, Jess.
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 4, padding: '0 4px 20px' }}>
          A minute of noticing. No wrong answers.
        </div>

        <CheckinCard t={t}
          mood={mood} onMood={setMood}
          readiness={readiness} onReadiness={setReadiness}
          prompt="What's one small thing you're grateful for today?"
          journal={journal} onJournal={setJournal}/>

        <div style={{ marginTop: 16 }}>
          <MMButton t={t} variant={mood ? 'primary' : 'ghost'} onClick={save}>
            {mood ? 'Save & see today' : 'Pick a mood to save'}
          </MMButton>
        </div>

        <div style={{ marginTop: 10, ...typeStyle(t.type.footnote, t.family), color: t.color.textTertiary,
          textAlign: 'center', padding: '0 16px', lineHeight: '17px' }}>
          Your check-ins stay on your device unless you choose to sync.
        </div>
      </div>
    </>
  );
}

Object.assign(window, { HomeScreen, DetailScreen, CheckinScreen, WeekBars });
