\NeedsTeXFormat{LaTeX2e}
\ProvidesExplClass
  {journal}
  {2026-09-30}
  {0.1}
  {Учебный журнальный класс}

\LoadClass{article}

\ExplSyntaxOn

\prg_new_conditional:Nnn \journal_positive_int:n
  { T, F, TF }
  {
    \int_compare:nTF
      { #1 > 0 }
      { \prg_return_true: }
      { \prg_return_false: }
  }

\cs_new_eq:NN
  \journal_volume_valid:nTF
  \journal_positive_int:nTF

\cs_new_eq:NN
  \journal_issue_valid:nTF
  \journal_positive_int:nTF

\msg_new:nnn 
    {journal}
    {invalid-value}
    {
    Invalid~value~'#1'~for~field~'#2'.
    }

\cs_new_protected:Nn \journal_new_int_field:n
  {
    \int_new:c
      { g_journal_#1_int }

    \cs_new_protected:cn
      { journal_set_#1:n }
      {
        \cs_if_exist:cTF
          { journal_#1_valid:nTF }
          {
            \use:c
              { journal_#1_valid:nTF }
              { ##1 }
              {
                \int_gset:cn
                  { g_journal_#1_int }
                  { ##1 }
              }
              {
                \msg_error:nnnn
                   {journal}
                   {invalid-value}
                   {##1}
                   {#1}
              }
          }
          {
            \int_gset:cn
              { g_journal_#1_int }
              { ##1 }
          }
      }
    
      \cs_new:cn
        { journal_#1: }
        {
            \int_use:c {g_journal_#1_int}
        } 

      \keys_define:nn
        { journal }
        {
          #1 .code:n =
            {
              \use:c { journal_set_#1:n } { ##1 }
            },
          #1 .value_required:n = true,
        }
  }

\clist_map_function:nN
  { volume, issue, year }
  \journal_new_int_field:n

\NewDocumentCommand \JournalSetup { m }
  {
    \keys_set:nn { journal } { #1 }
  }

\NewExpandableDocumentCommand \JournalVolume { }
  {
    \journal_volume:
  }

\NewExpandableDocumentCommand \JournalIssue { }
  {
    \journal_issue:
  }

\NewExpandableDocumentCommand \JournalYear { }
  {
    \journal_year:
  }

\ExplSyntaxOff
