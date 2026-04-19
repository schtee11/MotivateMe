// progress.jsx — Progress tab: trend, PRs, body measurements, weekly summary

function ProgressScreen({ t, onBack, dayOne }) {
  if (dayOne && typeof ProgressEmpty !== 'undefined') return <ProgressEmpty t={t} onBack={onBack}/>;
  const [range, setRange] = React.useState('month');

  return (
    <>
      <div style={{ padding: '54px 20px 4px', background: t.color.bg }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 34 }}>
          <span style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary, textTransform: 'uppercase', letterSpacing: 0.8 }}>
            Last {range === 'week' ? '7 days' : range === 'month' ? '30 days' : '90 days'}
          </span>
          <button style={{ border: 'none', background: 'transparent', cursor: 'pointer', padding: 4 }}>
            <Icon name="filter" size={20} color={t.color.textSecondary}/>
          </button>
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, marginTop: 8, letterSpacing: -0.8 }}>
          Your rhythm
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
          Steady beats loud. You're doing it.
        </div>
      </div>

      <div style={{ padding: '16px 16px 100px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <MMSegmented t={t} value={range} onChange={setRange}
          options={[{value:'week',label:'Week'},{value:'month',label:'Month'},{value:'quarter',label:'90 days'}]}/>

        {/* Headline streak + readiness */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <HeadlineStat t={t} label="Current streak" value="13" unit="days" icon="flame" hue="primary"/>
          <HeadlineStat t={t} label="Avg readiness" value="7.2" unit="/ 10" icon="sun" hue="secondary"/>
        </div>

        {/* Trend line */}
        <div style={{ padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>Workout volume</div>
            <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.secondary, fontWeight: 600 }}>
              ↑ 18% vs last month
            </div>
          </div>
          <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary, marginTop: 2 }}>
            Total sets per week
          </div>
          <div style={{ marginTop: 16 }}>
            <TrendLine t={t}/>
          </div>
        </div>

        {/* PR celebrations */}
        <div style={{ padding: 18, borderRadius: t.radius.card,
          background: `linear-gradient(155deg, ${t.color.primaryTint}, ${t.color.surfaceCard} 80%)`,
          boxShadow: t.elev.sm, position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', top: -30, right: -30, width: 120, height: 120, borderRadius: '50%',
            background: `radial-gradient(circle, ${t.color.primary}1f, transparent 70%)` }}/>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 14 }}>
            <Icon name="trophy" size={18} color={t.color.primary}/>
            <span style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 700, letterSpacing: 0.5,
              textTransform: 'uppercase', color: t.color.primary }}>Personal bests</span>
            <span style={{ flex: 1 }}/>
            <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textTertiary }}>this month</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <PRRow t={t} name="Deadlift" from="175" to="185" unit="lb" when="3 days ago"/>
            <PRRow t={t} name="Overhead press" from="85" to="90" unit="lb" when="last week"/>
            <PRRow t={t} name="Pull-ups" from="8" to="10" unit="reps" when="2 weeks ago"/>
          </div>
        </div>

        {/* Weekly summary card */}
        <div style={{ padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <Icon name="calendar" size={16} color={t.color.textSecondary}/>
            <span style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 700, letterSpacing: 0.5,
              textTransform: 'uppercase', color: t.color.textTertiary }}>This week</span>
          </div>
          <div style={{
            fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
            fontSize: 21, lineHeight: '29px', letterSpacing: -0.2,
            color: t.color.textPrimary,
          }}>
            Four out of five planned workouts. A walk every morning. One rest day, taken on purpose. <span style={{ color: t.color.primary, fontStyle: 'italic' }}>That's a lot of small yeses.</span>
          </div>
        </div>

        {/* Body measurement tracker */}
        <div style={{ padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
            <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>Body</div>
            <button style={{ border: 'none', background: 'transparent', cursor: 'pointer',
              fontFamily: t.family.rounded, fontSize: 13, fontWeight: 600, color: t.color.primary }}>
              Log +
            </button>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <MeasureRow t={t} label="Weight" value="168.2" unit="lb" delta="-1.4" trend="down" good/>
            <MeasureRow t={t} label="Resting HR" value="58" unit="bpm" delta="-3" trend="down" good/>
            <MeasureRow t={t} label="Sleep" value="7.4" unit="hrs avg" delta="+0.3" trend="up" good/>
          </div>
        </div>

        {/* Readiness heatmap */}
        <div style={{ padding: 18, borderRadius: t.radius.card,
          background: t.color.surfaceCard, boxShadow: t.elev.sm }}>
          <div style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>Readiness</div>
          <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary, marginTop: 2, marginBottom: 14 }}>
            84 days of morning check-ins
          </div>
          <Heatmap t={t} data={readinessData}/>
        </div>
      </div>
    </>
  );
}

const readinessData = Array.from({ length: 84 }).map((_, i) => {
  const r = Math.sin(i * 0.61) * 0.45 + 0.55 + (i > 70 ? 0.15 : 0);
  if (i < 4) return 0;
  if (r > 0.78) return 1;
  if (r > 0.55) return 0.66;
  if (r > 0.32) return 0.32;
  return 0;
});

function HeadlineStat({ t, label, value, unit, icon, hue = 'primary' }) {
  const c = hue === 'primary' ? t.color.primary : t.color.secondary;
  const tint = hue === 'primary' ? t.color.primaryTint : t.color.secondaryTint;
  const muted = hue === 'primary' ? t.color.primaryMuted : t.color.secondaryMuted;
  return (
    <div style={{ padding: 14, borderRadius: t.radius.card,
      background: `linear-gradient(160deg, ${tint}, ${t.color.surfaceCard} 85%)`,
      boxShadow: t.elev.sm, position: 'relative', overflow: 'hidden' }}>
      <div style={{ width: 30, height: 30, borderRadius: 9, background: muted,
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={icon} size={16} color={c} filled={icon === 'flame'}/>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 4, marginTop: 12 }}>
        <span style={{ fontFamily: t.family.rounded, fontSize: 34, fontWeight: 700, letterSpacing: -1,
          color: t.color.textPrimary }}>{value}</span>
        <span style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary }}>{unit}</span>
      </div>
      <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary, marginTop: 2 }}>
        {label}
      </div>
    </div>
  );
}

function TrendLine({ t }) {
  const data = [32, 38, 35, 44, 41, 48, 52, 47, 55, 58, 54, 62];
  const labels = ['W1','','W3','','W5','','W7','','W9','','W11','W12'];
  const max = 70, min = 0;
  const width = 300, height = 120;
  const step = width / (data.length - 1);
  const points = data.map((v, i) => [i * step, height - ((v - min) / (max - min)) * height]);
  const d = points.map((p, i) => (i === 0 ? `M ${p[0]} ${p[1]}` : `L ${p[0]} ${p[1]}`)).join(' ');
  const area = d + ` L ${width} ${height} L 0 ${height} Z`;
  const last = points[points.length - 1];

  return (
    <div>
      <svg viewBox={`0 0 ${width} ${height + 24}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
        <defs>
          <linearGradient id="trendFill" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={t.color.primary} stopOpacity="0.22"/>
            <stop offset="100%" stopColor={t.color.primary} stopOpacity="0"/>
          </linearGradient>
        </defs>
        <path d={area} fill="url(#trendFill)"/>
        <path d={d} fill="none" stroke={t.color.primary} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
        {points.map((p, i) => (i === points.length - 1) && (
          <g key={i}>
            <circle cx={p[0]} cy={p[1]} r="8" fill={t.color.primary} opacity="0.18"/>
            <circle cx={p[0]} cy={p[1]} r="4.5" fill={t.color.primary} stroke={t.color.surfaceCard} strokeWidth="2"/>
          </g>
        ))}
        {labels.map((l, i) => l && (
          <text key={i} x={i * step} y={height + 18}
            fontFamily={t.family.mono} fontSize="9" fill={t.color.textTertiary}
            textAnchor={i === 0 ? 'start' : i === labels.length - 1 ? 'end' : 'middle'}>{l}</text>
        ))}
      </svg>
    </div>
  );
}

function PRRow({ t, name, from, to, unit, when }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12,
      padding: 10, borderRadius: 12, background: t.color.surface }}>
      <div style={{ width: 32, height: 32, borderRadius: 9, background: t.color.primaryMuted,
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name="sparkles" size={16} color={t.color.primary}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...typeStyle(t.type.footnote, t.family), fontWeight: 600, color: t.color.textPrimary }}>{name}</div>
        <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>{when}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
        <span style={{ fontFamily: t.family.mono, fontSize: 13, color: t.color.textTertiary, textDecoration: 'line-through' }}>{from}</span>
        <Icon name="arrowRight" size={12} color={t.color.textTertiary} strokeWidth={2}/>
        <span style={{ fontFamily: t.family.rounded, fontSize: 16, fontWeight: 700, color: t.color.primary }}>{to}</span>
        <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>{unit}</span>
      </div>
    </div>
  );
}

function MeasureRow({ t, label, value, unit, delta, trend, good }) {
  const deltaColor = good ? t.color.secondary : t.color.textSecondary;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
      <div style={{ flex: 1 }}>
        <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textPrimary }}>{label}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
        <span style={{ fontFamily: t.family.rounded, fontSize: 20, fontWeight: 700, color: t.color.textPrimary, letterSpacing: -0.4 }}>{value}</span>
        <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>{unit}</span>
      </div>
      <div style={{ width: 56, textAlign: 'right', fontFamily: t.family.mono, fontSize: 12, color: deltaColor }}>
        {delta}
      </div>
    </div>
  );
}

Object.assign(window, { ProgressScreen });
