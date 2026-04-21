// empty-states.jsx — Day-one / zero-state views for Home, Progress, History, Journal.
// Shared visual language: one illustrative mark, a warm sentence, one clear action.

function EmptyFrame({ t, mark, title, body, primaryLabel, onPrimary, secondaryLabel, onSecondary, footnote, tone = 'primary' }) {
  const accent = tone === 'secondary' ? t.color.secondary : t.color.primary;
  const tint   = tone === 'secondary' ? t.color.secondaryTint : t.color.primaryTint;
  return (
    <div style={{
      padding: '44px 28px 60px',
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      textAlign: 'center', minHeight: '70%',
    }}>
      {/* Illustrative mark */}
      <div style={{
        width: 120, height: 120, borderRadius: '50%',
        background: `radial-gradient(circle at 50% 55%, ${tint}, transparent 70%)`,
        position: 'relative',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        marginBottom: 20,
      }}>
        {mark}
      </div>

      <div style={{
        fontFamily: t.family.serif || t.family.rounded,
        fontSize: 26, fontWeight: 600, lineHeight: 1.2,
        color: t.color.textPrimary, letterSpacing: -0.4,
        fontStyle: t.family.serif ? 'italic' : 'normal',
        maxWidth: 280, textWrap: 'balance',
      }}>
        {title}
      </div>
      <div style={{
        ...typeStyle(t.type.body, t.family),
        color: t.color.textSecondary, marginTop: 10,
        maxWidth: 300, textWrap: 'balance', lineHeight: 1.45,
      }}>
        {body}
      </div>

      {primaryLabel && (
        <button onClick={onPrimary}
          style={{
            marginTop: 24, padding: '13px 22px',
            borderRadius: t.radius.pill, border: 'none', cursor: 'pointer',
            background: accent, color: t.color.onPrimary,
            fontFamily: t.family.rounded, fontSize: 15, fontWeight: 700,
            boxShadow: t.elev.sm, letterSpacing: -0.1,
          }}>
          {primaryLabel}
        </button>
      )}

      {secondaryLabel && (
        <button onClick={onSecondary}
          style={{
            marginTop: 10, padding: '10px', border: 'none',
            background: 'transparent', cursor: 'pointer',
            color: t.color.textSecondary, fontFamily: t.family.text,
            fontSize: 14, fontWeight: 500,
          }}>
          {secondaryLabel}
        </button>
      )}

      {footnote && (
        <div style={{
          ...typeStyle(t.type.caption1, t.family),
          color: t.color.textTertiary, marginTop: 22,
          maxWidth: 280, fontStyle: 'italic', lineHeight: 1.4,
        }}>
          {footnote}
        </div>
      )}
    </div>
  );
}

// Small illustrative marks — not icons, not AI-slop gradients. Quiet geometric suggestions.

function MarkSunrise({ t, size = 64 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <circle cx="32" cy="38" r="14" fill={t.color.primary}/>
      <line x1="10" y1="52" x2="54" y2="52" stroke={t.color.primary} strokeWidth="1.5" strokeLinecap="round" opacity="0.5"/>
      <line x1="6"  y1="56" x2="58" y2="56" stroke={t.color.secondary} strokeWidth="1" strokeLinecap="round" opacity="0.4"/>
    </svg>
  );
}
function MarkSeed({ t, size = 64 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <ellipse cx="32" cy="36" rx="7" ry="11" fill={t.color.primary}/>
      <path d="M32 25 C 32 18, 28 16, 26 18" stroke={t.color.secondary} strokeWidth="1.5" strokeLinecap="round" fill="none"/>
      <path d="M32 25 C 32 18, 36 16, 38 18" stroke={t.color.secondary} strokeWidth="1.5" strokeLinecap="round" fill="none"/>
      <line x1="18" y1="50" x2="46" y2="50" stroke={t.color.border} strokeWidth="1" strokeLinecap="round"/>
    </svg>
  );
}
function MarkPage({ t, size = 64 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <rect x="18" y="12" width="28" height="40" rx="3" fill={t.color.surfaceCard} stroke={t.color.primary} strokeWidth="1.5"/>
      <line x1="24" y1="22" x2="40" y2="22" stroke={t.color.primary} strokeWidth="1" opacity="0.35"/>
      <line x1="24" y1="28" x2="36" y2="28" stroke={t.color.primary} strokeWidth="1" opacity="0.25"/>
      <line x1="24" y1="34" x2="38" y2="34" stroke={t.color.primary} strokeWidth="1" opacity="0.2"/>
    </svg>
  );
}
function MarkEmptyCal({ t, size = 64 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <rect x="14" y="16" width="36" height="36" rx="4" fill={t.color.surfaceCard} stroke={t.color.primary} strokeWidth="1.5"/>
      <line x1="14" y1="24" x2="50" y2="24" stroke={t.color.primary} strokeWidth="1.5"/>
      <line x1="22" y1="12" x2="22" y2="20" stroke={t.color.primary} strokeWidth="1.5" strokeLinecap="round"/>
      <line x1="42" y1="12" x2="42" y2="20" stroke={t.color.primary} strokeWidth="1.5" strokeLinecap="round"/>
      <circle cx="32" cy="38" r="1.5" fill={t.color.textTertiary}/>
      <circle cx="24" cy="38" r="1.5" fill={t.color.textTertiary}/>
      <circle cx="40" cy="38" r="1.5" fill={t.color.textTertiary}/>
    </svg>
  );
}
function MarkChart({ t, size = 64 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <line x1="14" y1="50" x2="54" y2="50" stroke={t.color.border} strokeWidth="1"/>
      <line x1="14" y1="50" x2="14" y2="14" stroke={t.color.border} strokeWidth="1"/>
      <circle cx="22" cy="44" r="2.5" fill={t.color.primary}/>
      <path d="M22 44 L 32 44 L 42 44 L 52 44" stroke={t.color.primary} strokeWidth="1.5" strokeLinecap="round" strokeDasharray="3 4" opacity="0.4"/>
    </svg>
  );
}

// ── Home empty state ─────────────────────────────────────

function HomeEmpty({ t, dispatch }) {
  return (
    <div>
      {/* Top strip */}
      <div style={{ padding: '54px 20px 8px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', minHeight: 34 }}>
          <button onClick={() => dispatch({ type: 'goto', screen: 'settings' })}
            style={{
              width: 36, height: 36, borderRadius: 18, background: t.color.secondaryMuted,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              border: 'none', cursor: 'pointer', padding: 0,
            }}>
            <span style={{ fontFamily: t.family.rounded, fontWeight: 600, color: t.color.secondary, fontSize: 14 }}>JS</span>
          </button>
          <button style={{ border: 'none', background: 'transparent', padding: 4, opacity: 0.5 }}>
            <Icon name="bell" size={22} color={t.color.textSecondary}/>
          </button>
        </div>
        <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 14 }}>
          {new Date().toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, marginTop: 2 }}>
          Hi, Jess
        </div>
      </div>

      <div style={{ padding: '4px 16px 100px' }}>
        {/* Welcome card */}
        <div style={{
          marginTop: 8, padding: '20px 20px 18px', borderRadius: t.radius.cardLg,
          background: `linear-gradient(160deg, ${t.color.primaryTint}, ${t.color.surfaceCard})`,
          boxShadow: t.elev.sm,
          display: 'flex', flexDirection: 'column', gap: 10,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <MarkSunrise t={t} size={44}/>
            <div style={{
              ...typeStyle(t.type.caption2, t.family),
              color: t.color.primary, fontWeight: 700,
              textTransform: 'uppercase', letterSpacing: 1,
            }}>
              Day one
            </div>
          </div>
          <div style={{
            fontFamily: t.family.serif || t.family.rounded,
            fontSize: 22, fontWeight: 600, lineHeight: 1.25,
            color: t.color.textPrimary, letterSpacing: -0.3,
            fontStyle: t.family.serif ? 'italic' : 'normal',
            textWrap: 'balance',
          }}>
            Welcome. Let\u2019s keep it small today.
          </div>
          <div style={{
            ...typeStyle(t.type.footnote, t.family),
            color: t.color.textSecondary, lineHeight: 1.45,
          }}>
            A good first day isn\u2019t heroic — it\u2019s just one thing you do that you\u2019ll want to do again tomorrow.
          </div>
          <button onClick={() => dispatch({ type: 'goto', screen: 'checkin' })}
            style={{
              alignSelf: 'flex-start', marginTop: 4, padding: '10px 16px',
              borderRadius: t.radius.pill, border: 'none', cursor: 'pointer',
              background: t.color.primary, color: t.color.onPrimary,
              fontFamily: t.family.rounded, fontSize: 14, fontWeight: 700,
              boxShadow: t.elev.xs,
            }}>
            Start with a check-in
          </button>
        </div>

        {/* Today's plan with empty row + add */}
        <div style={{ marginTop: 22 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '0 4px 10px' }}>
            <div style={{ ...typeStyle(t.type.title3, t.family), color: t.color.textPrimary }}>
              Today\u2019s plan
            </div>
            <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textTertiary, fontStyle: 'italic' }}>
              nothing yet
            </div>
          </div>

          {/* Big empty CTA */}
          <button onClick={() => dispatch({ type: 'goto', screen: 'habitNew' })}
            style={{
              width: '100%', padding: '20px 18px',
              borderRadius: t.radius.card,
              background: t.color.surfaceCard, boxShadow: t.elev.xs,
              border: `1.5px dashed ${t.color.border}`,
              cursor: 'pointer', textAlign: 'left',
              display: 'flex', alignItems: 'center', gap: 14,
            }}>
            <div style={{
              width: 44, height: 44, borderRadius: 14,
              background: t.color.primaryTint,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0,
            }}>
              <Icon name="plus" size={22} color={t.color.primary} strokeWidth={2.4}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ ...typeStyle(t.type.headline, t.family),
                color: t.color.textPrimary, fontWeight: 600 }}>
                Add your first habit
              </div>
              <div style={{ ...typeStyle(t.type.footnote, t.family),
                color: t.color.textSecondary, marginTop: 2, lineHeight: 1.4 }}>
                Start with one. Add more when it feels easy.
              </div>
            </div>
            <Icon name="chevronRight" size={16} color={t.color.textTertiary}/>
          </button>

          {/* Suggested starters */}
          <div style={{ marginTop: 18, padding: '0 4px 8px',
            ...typeStyle(t.type.caption2, t.family),
            color: t.color.textTertiary, textTransform: 'uppercase', letterSpacing: 1 }}>
            Gentle starters
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {[
              { icon: 'figure', color: '#8BA76B', title: 'Morning walk',     sub: '10 minutes · any pace' },
              { icon: 'leaf',   color: '#7AA5B8', title: 'Stretch & breathe', sub: '5 minutes · after coffee' },
              { icon: 'book',   color: '#A08BB5', title: 'One-line journal',  sub: '2 minutes · before bed' },
            ].map(s => (
              <button key={s.title}
                onClick={() => dispatch({ type: 'goto', screen: 'habitNew' })}
                style={{
                  padding: '12px 14px', borderRadius: 14, cursor: 'pointer',
                  background: t.color.surfaceCard, boxShadow: t.elev.xs,
                  border: 'none',
                  display: 'flex', alignItems: 'center', gap: 12, textAlign: 'left',
                }}>
                <div style={{
                  width: 34, height: 34, borderRadius: 10,
                  background: s.color,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <Icon name={s.icon} size={16} color="#fff"/>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ ...typeStyle(t.type.callout, t.family),
                    color: t.color.textPrimary, fontWeight: 500 }}>
                    {s.title}
                  </div>
                  <div style={{ ...typeStyle(t.type.caption1, t.family),
                    color: t.color.textTertiary }}>
                    {s.sub}
                  </div>
                </div>
                <Icon name="plus" size={14} color={t.color.textTertiary} strokeWidth={2.2}/>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ── Progress empty ──────────────────────────────────────

function ProgressEmpty({ t, onBack }) {
  return (
    <div style={{ padding: '54px 0 100px' }}>
      <div style={{ padding: '0 20px' }}>
        <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
          textTransform: 'uppercase', letterSpacing: 0.8 }}>
          Progress
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary,
          marginTop: 8, letterSpacing: -0.8 }}>
          Your first week
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
          Something to look at here by Sunday.
        </div>
      </div>

      <div style={{ padding: '22px 16px 0' }}>
        <EmptyFrame t={t}
          mark={<MarkChart t={t}/>}
          title="Nothing to measure yet — and that's okay."
          body="Charts, trends, and patterns need a few days of life to live in. Show up a handful of times and this page will start to feel like yours."
          footnote="We don\u2019t grade early days. Consistency finds you, not the other way around."/>

        {/* Preview strip of what's coming */}
        <div style={{ margin: '20px 16px 0', padding: '16px', borderRadius: 16,
          background: t.color.surfaceCard, boxShadow: t.elev.xs }}>
          <div style={{ ...typeStyle(t.type.caption2, t.family),
            color: t.color.textTertiary, textTransform: 'uppercase', letterSpacing: 0.8, marginBottom: 8 }}>
            What you\u2019ll see here
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {[
              'Weekly consistency, shown softly',
              'How readiness + mood shift over time',
              'Quiet wins (a line of the week in your own words)',
            ].map(s => (
              <div key={s} style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
                <div style={{ width: 4, height: 4, borderRadius: 2,
                  background: t.color.primary, marginTop: 8, flexShrink: 0 }}/>
                <div style={{ ...typeStyle(t.type.footnote, t.family),
                  color: t.color.textSecondary, lineHeight: 1.4 }}>
                  {s}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ── History empty ───────────────────────────────────────

function HistoryEmpty({ t }) {
  return (
    <div style={{ padding: '54px 0 100px' }}>
      <div style={{ padding: '0 20px' }}>
        <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
          textTransform: 'uppercase', letterSpacing: 0.8 }}>
          History
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary,
          marginTop: 8, letterSpacing: -0.8 }}>
          Today is page one
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
          Every session will land here.
        </div>
      </div>

      <div style={{ padding: '22px 16px 0' }}>
        <EmptyFrame t={t} tone="secondary"
          mark={<MarkEmptyCal t={t}/>}
          title="Nothing behind you yet."
          body="That\u2019s fine. A history is just a series of days you showed up for — and the first one counts just as much."
          footnote="No backfilling, no pretending. We start from where you are."/>
      </div>
    </div>
  );
}

// ── Journal empty ───────────────────────────────────────

function JournalEmpty({ t, onCompose }) {
  return (
    <div style={{ padding: '54px 0 100px' }}>
      <div style={{ padding: '0 20px' }}>
        <div style={{ ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary,
          textTransform: 'uppercase', letterSpacing: 0.8 }}>
          Journal
        </div>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary,
          marginTop: 8, letterSpacing: -0.8 }}>
          A quiet place
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
          One line a day is plenty.
        </div>
      </div>

      <div style={{ padding: '22px 16px 0' }}>
        <EmptyFrame t={t}
          mark={<MarkPage t={t}/>}
          title="The first page is always the hardest."
          body="You don\u2019t need to be a writer. Just finish one of the prompts below — that\u2019s it, that\u2019s the whole thing."
          primaryLabel="Write a line"
          onPrimary={onCompose}/>

        {/* Prompt chips */}
        <div style={{ padding: '20px 12px 0' }}>
          <div style={{
            ...typeStyle(t.type.caption2, t.family),
            color: t.color.textTertiary, textTransform: 'uppercase', letterSpacing: 0.8,
            padding: '0 4px 8px',
          }}>
            Start here
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {[
              'Today, I noticed…',
              'Something small I\u2019m proud of today is…',
              'One thing that wore me out today was…',
              'If tomorrow went well, it would look like…',
            ].map(p => (
              <button key={p} onClick={onCompose}
                style={{
                  padding: '14px 16px', borderRadius: 14, cursor: 'pointer',
                  background: t.color.surfaceCard, boxShadow: t.elev.xs,
                  border: 'none', textAlign: 'left',
                  display: 'flex', alignItems: 'center', gap: 10,
                }}>
                <div style={{
                  fontFamily: t.family.serif || t.family.rounded,
                  fontSize: 24, color: t.color.secondary, lineHeight: 0.7,
                  fontStyle: 'italic', flexShrink: 0, marginTop: 6,
                }}>
                  "
                </div>
                <div style={{
                  flex: 1,
                  fontFamily: t.family.serif || t.family.rounded,
                  fontSize: 15, color: t.color.textPrimary, lineHeight: 1.4,
                  fontStyle: t.family.serif ? 'italic' : 'normal',
                }}>
                  {p}
                </div>
                <Icon name="pencil" size={14} color={t.color.textTertiary}/>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  HomeEmpty, ProgressEmpty, HistoryEmpty, JournalEmpty,
});
