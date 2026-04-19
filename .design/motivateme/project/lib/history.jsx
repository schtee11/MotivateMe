// history.jsx — History screen: past sessions grouped by day, filter chips, search, expandable rows

const HISTORY_SESSIONS = [
  // Today is "Tue, Apr 15" in our fiction
  { id: 's1', day: 0,  title: 'Upper body — Push',  category: 'Strength', duration: 34, icon: 'dumbbell',
    note: 'Bench felt strong. Left shoulder quiet today — good.', pr: 'Bench 185×5', sets: 18, volume: 4280 },
  { id: 's2', day: 0,  title: 'Morning walk',        category: 'Movement', duration: 22, icon: 'figure',
    note: 'Sun was out. Took the long way past the pond.', sets: null, volume: null },
  { id: 's3', day: 1,  title: 'Evening journal',     category: 'Reflect',  duration: 4,  icon: 'book',
    note: 'One line — proud of how I handled that meeting.' },
  { id: 's4', day: 1,  title: 'Stretch & breathe',   category: 'Mobility', duration: 9,  icon: 'leaf',
    note: 'Hips loosened up around round three.' },
  { id: 's5', day: 1,  title: 'Morning walk',        category: 'Movement', duration: 25, icon: 'figure',
    note: '' },
  { id: 's6', day: 2,  title: 'Lower body — Legs',   category: 'Strength', duration: 42, icon: 'dumbbell',
    note: 'Squats heavy but clean. Knees happy.', pr: 'Squat 205×3', sets: 22, volume: 5640 },
  { id: 's7', day: 2,  title: 'Morning walk',        category: 'Movement', duration: 20, icon: 'figure' },
  { id: 's8', day: 3,  title: 'Evening journal',     category: 'Reflect',  duration: 3,  icon: 'book',
    note: 'Tired. Still showed up.' },
  { id: 's9', day: 4,  title: 'Upper body — Pull',   category: 'Strength', duration: 36, icon: 'dumbbell',
    note: 'Rows were the star today.', sets: 20, volume: 4120 },
  { id: 's10', day: 4, title: 'Morning walk',        category: 'Movement', duration: 28, icon: 'figure' },
  { id: 's11', day: 5, title: 'Stretch & breathe',   category: 'Mobility', duration: 8,  icon: 'leaf' },
  { id: 's12', day: 6, title: 'Evening journal',     category: 'Reflect',  duration: 5,  icon: 'book',
    note: 'Short one. Grateful for the quiet.' },
  { id: 's13', day: 6, title: 'Morning walk',        category: 'Movement', duration: 31, icon: 'figure',
    note: 'Rain. Went anyway. Small win.' },
  { id: 's14', day: 7, title: 'Upper body — Push',   category: 'Strength', duration: 33, icon: 'dumbbell',
    note: 'Decent. Paced it well.', sets: 18, volume: 4110 },
  { id: 's15', day: 8, title: 'Evening journal',     category: 'Reflect',  duration: 4,  icon: 'book' },
  { id: 's16', day: 9, title: 'Lower body — Legs',   category: 'Strength', duration: 41, icon: 'dumbbell',
    note: 'Good session, a bit under-recovered.', sets: 21, volume: 5420 },
  { id: 's17', day: 10,title: 'Morning walk',        category: 'Movement', duration: 19, icon: 'figure' },
  { id: 's18', day: 11,title: 'Stretch & breathe',   category: 'Mobility', duration: 11, icon: 'leaf',
    note: 'Four rounds, breath got slower. Felt clear after.' },
];

function dayLabel(offset) {
  // Day 0 = Today, 1 = Yesterday, else weekday + date
  const today = new Date(2026, 3, 14); // Tue Apr 14 2026
  const d = new Date(today); d.setDate(today.getDate() - offset);
  if (offset === 0) return { main: 'Today', sub: formatDate(d) };
  if (offset === 1) return { main: 'Yesterday', sub: formatDate(d) };
  const weekday = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][d.getDay()];
  return { main: weekday + 'day'.slice(0,0) === '' ? ({Sun:'Sunday',Mon:'Monday',Tue:'Tuesday',Wed:'Wednesday',Thu:'Thursday',Fri:'Friday',Sat:'Saturday'}[weekday]) : weekday, sub: formatDate(d) };
}
function formatDate(d) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.getMonth()];
  return `${m} ${d.getDate()}`;
}
function fullWeekday(d) {
  return ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'][d.getDay()];
}

function HistoryScreen({ t, onBack, dayOne }) {
  if (dayOne && typeof HistoryEmpty !== 'undefined') return <HistoryEmpty t={t}/>;
  const [filter, setFilter] = React.useState('all');
  const [query, setQuery] = React.useState('');
  const [openId, setOpenId] = React.useState(null);

  const filters = [
    { key: 'all', label: 'All' },
    { key: 'Strength', label: 'Strength' },
    { key: 'Movement', label: 'Movement' },
    { key: 'Mobility', label: 'Mobility' },
    { key: 'Reflect', label: 'Reflect' },
  ];

  const filtered = HISTORY_SESSIONS.filter(s => {
    if (filter !== 'all' && s.category !== filter) return false;
    if (query && !(s.title + ' ' + (s.note||'')).toLowerCase().includes(query.toLowerCase())) return false;
    return true;
  });

  // Group by day
  const groups = {};
  filtered.forEach(s => { (groups[s.day] ||= []).push(s); });
  const dayOffsets = Object.keys(groups).map(Number).sort((a,b) => a-b);

  // Summary math for header
  const totalSessions = HISTORY_SESSIONS.length;
  const totalMinutes = HISTORY_SESSIONS.reduce((a,s) => a + (s.duration||0), 0);
  const daysActive = new Set(HISTORY_SESSIONS.map(s => s.day)).size;

  return (
    <>
      {/* Large-title nav area */}
      <div style={{ padding: '54px 20px 4px', background: t.color.bg }}>
        <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary, textTransform: 'uppercase', letterSpacing: 0.8 }}>
          Last 12 days
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, marginTop: 8, letterSpacing: -0.8 }}>
          History
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
          Every session you showed up for. Nothing lost.
        </div>
      </div>

      <div style={{ padding: '14px 16px 100px', display: 'flex', flexDirection: 'column', gap: 14 }}>

        {/* Summary strip */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8,
          padding: 14, borderRadius: t.radius.card, background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <SummaryStat t={t} label="Sessions" value={totalSessions}/>
          <SummaryStat t={t} label="Minutes"  value={totalMinutes}/>
          <SummaryStat t={t} label="Days active" value={daysActive}/>
        </div>

        {/* Search */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          padding: '10px 12px', borderRadius: t.radius.pill,
          background: t.color.surfaceCard, boxShadow: t.elev.sm,
        }}>
          <Icon name="search" size={16} color={t.color.textTertiary}/>
          <input value={query} onChange={e => setQuery(e.target.value)}
            placeholder="Search sessions & notes"
            style={{
              flex: 1, border: 'none', outline: 'none', background: 'transparent',
              fontFamily: t.family.text, fontSize: t.type.callout.size, color: t.color.textPrimary,
            }}/>
          {query && (
            <button onClick={() => setQuery('')} style={{ border: 'none', background: 'transparent', cursor: 'pointer', padding: 2 }}>
              <Icon name="close" size={14} color={t.color.textTertiary}/>
            </button>
          )}
        </div>

        {/* Category chips — horizontally scrollable */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto', padding: '2px 2px 4px',
          margin: '-2px -2px 0', WebkitOverflowScrolling: 'touch', scrollbarWidth: 'none',
        }}>
          <style>{`.mm-chip-row::-webkit-scrollbar{display:none}`}</style>
          {filters.map(f => (
            <button key={f.key} onClick={() => setFilter(f.key)}
              style={{
                flex: '0 0 auto',
                padding: '7px 14px', borderRadius: t.radius.pill,
                border: filter === f.key ? 'none' : `1px solid ${t.color.border}`,
                background: filter === f.key ? t.color.primary : 'transparent',
                color: filter === f.key ? t.color.onPrimary : t.color.textSecondary,
                fontFamily: t.family.rounded, fontSize: 14, fontWeight: 600,
                cursor: 'pointer',
                transition: 'all 160ms cubic-bezier(0.34, 1.2, 0.64, 1)',
              }}>
              {f.label}
            </button>
          ))}
        </div>

        {/* Empty state */}
        {filtered.length === 0 && (
          <div style={{
            padding: '32px 20px', borderRadius: t.radius.card,
            background: t.color.surfaceCard, boxShadow: t.elev.sm, textAlign: 'center',
          }}>
            <div style={{ ...typeStyle(t.type.title3, t.family), color: t.color.textPrimary, marginBottom: 4 }}>
              Nothing here yet
            </div>
            <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary }}>
              Try a different filter — or go make some history.
            </div>
          </div>
        )}

        {/* Day groups */}
        {dayOffsets.map(offset => {
          const label = dayLabel(offset);
          const sessions = groups[offset];
          const dayMinutes = sessions.reduce((a,s) => a + (s.duration||0), 0);
          return (
            <div key={offset}>
              {/* Day header */}
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
                padding: '4px 4px 10px' }}>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
                  <span style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>
                    {label.main}
                  </span>
                  <span style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textTertiary }}>
                    {label.sub}
                  </span>
                </div>
                <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary,
                  fontFamily: t.family.mono, letterSpacing: 0.4 }}>
                  {dayMinutes}m · {sessions.length}
                </span>
              </div>

              {/* Timeline-style list */}
              <div style={{ position: 'relative', paddingLeft: 22 }}>
                {/* Rail */}
                <div style={{
                  position: 'absolute', left: 7, top: 10, bottom: 10, width: 2,
                  background: t.color.border, borderRadius: 1,
                }}/>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {sessions.map(s => (
                    <HistoryRow key={s.id} t={t} session={s}
                      open={openId === s.id}
                      onToggle={() => setOpenId(openId === s.id ? null : s.id)}/>
                  ))}
                </div>
              </div>
            </div>
          );
        })}

        {/* Footer encouragement */}
        {filtered.length > 0 && (
          <div style={{
            marginTop: 6, padding: '14px 16px', borderRadius: t.radius.card,
            background: t.color.secondaryTint, textAlign: 'center',
          }}>
            <div style={{ fontFamily: t.family.serif || t.family.rounded,
              fontSize: 17, fontStyle: 'italic', color: t.color.textPrimary, lineHeight: 1.4 }}>
              “Every one of these is a vote for the person you're becoming.”
            </div>
          </div>
        )}
      </div>
    </>
  );
}

function SummaryStat({ t, label, value }) {
  return (
    <div style={{ textAlign: 'center' }}>
      <div style={{ fontFamily: t.family.rounded, fontSize: 24, fontWeight: 700,
        color: t.color.textPrimary, lineHeight: 1, letterSpacing: -0.4 }}>
        {value}
      </div>
      <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
        textTransform: 'uppercase', letterSpacing: 0.6, marginTop: 4 }}>
        {label}
      </div>
    </div>
  );
}

function HistoryRow({ t, session, open, onToggle }) {
  const catColor = {
    Strength: t.color.primary,
    Movement: t.color.secondary,
    Mobility: t.color.info || t.color.secondary,
    Reflect:  t.color.textSecondary,
  }[session.category] || t.color.primary;

  return (
    <div style={{ position: 'relative' }}>
      {/* Dot on the rail */}
      <div style={{
        position: 'absolute', left: -22, top: 18,
        width: 16, height: 16, borderRadius: 8,
        background: t.color.surfaceCard,
        border: `2px solid ${catColor}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <div style={{ width: 6, height: 6, borderRadius: 3, background: catColor }}/>
      </div>

      <button onClick={onToggle} style={{
        width: '100%', textAlign: 'left', cursor: 'pointer',
        padding: '12px 14px', borderRadius: t.radius.cardInner || 16,
        background: t.color.surfaceCard, boxShadow: t.elev.sm,
        border: 'none',
        transition: 'transform 180ms cubic-bezier(0.34, 1.2, 0.64, 1)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: `color-mix(in oklab, ${catColor} 14%, ${t.color.surfaceCard})`,
            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
          }}>
            <Icon name={session.icon} size={18} color={catColor}/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, justifyContent: 'space-between' }}>
              <div style={{ ...typeStyle(t.type.callout, t.family), color: t.color.textPrimary,
                fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                {session.title}
              </div>
              <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textTertiary,
                fontFamily: t.family.mono, flexShrink: 0 }}>
                {session.duration}m
              </div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 3 }}>
              <span style={{ ...typeStyle(t.type.caption1, t.family), color: catColor, fontWeight: 600,
                textTransform: 'uppercase', letterSpacing: 0.4 }}>
                {session.category}
              </span>
              {session.pr && (
                <>
                  <span style={{ color: t.color.textTertiary }}>·</span>
                  <span style={{
                    ...typeStyle(t.type.caption1, t.family), color: t.color.primary, fontWeight: 600,
                    display: 'inline-flex', alignItems: 'center', gap: 3,
                  }}>
                    <Icon name="flame" size={10} color={t.color.primary}/>
                    PR · {session.pr}
                  </span>
                </>
              )}
            </div>
          </div>
          <div style={{ transform: open ? 'rotate(90deg)' : 'rotate(0deg)',
            transition: 'transform 200ms cubic-bezier(0.34, 1.2, 0.64, 1)' }}>
            <Icon name="chevronRight" size={14} color={t.color.textTertiary}/>
          </div>
        </div>

        {/* Expanded detail */}
        {open && (
          <div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px solid ${t.color.border}`,
            display: 'flex', flexDirection: 'column', gap: 10 }}>
            {session.note ? (
              <div style={{
                fontFamily: t.family.serif || t.family.text,
                fontSize: 15, lineHeight: 1.55, color: t.color.textPrimary,
                fontStyle: t.family.serif ? 'italic' : 'normal',
              }}>
                “{session.note}”
              </div>
            ) : (
              <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textTertiary,
                fontStyle: 'italic' }}>
                No note this time.
              </div>
            )}

            {(session.sets || session.volume) && (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
                {session.sets != null && <MetricPill t={t} label="Sets" value={session.sets}/>}
                {session.volume != null && <MetricPill t={t} label="Volume" value={session.volume.toLocaleString() + ' lb'}/>}
              </div>
            )}
          </div>
        )}
      </button>
    </div>
  );
}

function MetricPill({ t, label, value }) {
  return (
    <div style={{
      padding: '8px 12px', borderRadius: 12,
      background: `color-mix(in oklab, ${t.color.border} 50%, ${t.color.surfaceCard})`,
      display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
    }}>
      <span style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
        textTransform: 'uppercase', letterSpacing: 0.6 }}>
        {label}
      </span>
      <span style={{ fontFamily: t.family.mono, fontSize: 13, fontWeight: 600, color: t.color.textPrimary,
        letterSpacing: 0.2 }}>
        {value}
      </span>
    </div>
  );
}

Object.assign(window, { HistoryScreen });
