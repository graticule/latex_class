\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{szf}[2026/09/11 Journal class]

% Режим отображения final/review

\newif\if@szfreview
\newif\if@szfrussian

\def\szf@review{review}
\def\szf@final{final}

\DeclareKeys[szf]
{
	mode.code = {%
		\def\szf@mode{#1}%
		\ifx\szf@mode\szf@review
		\@szfreviewtrue
		\else
			\ifx\szf@mode\szf@final
			\@szfreviewfalse
			\else
			\ClassError{szf}
			{Unknown mode `#1'}
			{Use mode=review or mode=final}%
			\fi
		\fi
	},
	mode.usage = load,
	language.choice:,
	language / russian.code = {\@szfrussiantrue},
	language / english.code = {\@szfrussianfalse},
	language.usage = load
}

% Значения по умолчанию
\SetKeys[szf]{
	mode=final,
	language=russian
}

% Затем пользовательские параметры их переопределяют
\ProcessKeyOptions[szf]

\ExplSyntaxOn

\tl_new:N \g_szf_language_tl

\if@szfrussian
  \tl_gset:Nn \g_szf_language_tl { russian }
\else
  \tl_gset:Nn \g_szf_language_tl { english }
\fi

\ExplSyntaxOff

% Загружаем базовый класс article
\if@szfreview
\LoadClass[a4paper,12pt,onecolumn]{article}
\else
\LoadClass[a4paper,10pt,twocolumn]{article}
\fi

% Определяем язык 
\RequirePackage[T2A]{fontenc}

\if@szfrussian
\RequirePackage[english,russian]{babel}
\else
\RequirePackage[russian,english]{babel}
\fi

\if@szfrussian
\def\szf@abstractname{Аннотация}
\def\szf@keywordsname{Ключевые слова}
\else
\def\szf@abstractname{Abstract}
\def\szf@keywordsname{Keywords}
\fi

% Собираем титульный лист

% --- Authors storage and interface ---

\ExplSyntaxOn

\int_new:N  \g_szf_author_int
\seq_new:N  \g_szf_author_order_seq
\prop_new:N \g_szf_author_prop

\clist_new:N \l_szf_author_affiliations_clist
\tl_new:N    \l_szf_author_email_tl
\bool_new:N  \l_szf_author_corresponding_bool

\keys_define:nn { szf / author }
  {
    affiliation .clist_set:N =
      \l_szf_author_affiliations_clist,

    email .tl_set:N =
      \l_szf_author_email_tl,

    corresponding .bool_set:N =
      \l_szf_author_corresponding_bool,

    corresponding .default:n = true
  }

\cs_generate_variant:Nn \prop_gput:Nnn { Nxn, NxV }
\cs_generate_variant:Nn \prop_get:NnN  { NxN }

\RenewDocumentCommand \author { O{} m }
  {
    \clist_clear:N \l_szf_author_affiliations_clist
    \tl_clear:N    \l_szf_author_email_tl
    \bool_set_false:N \l_szf_author_corresponding_bool

    \keys_set:nn { szf / author } {#1}

    \int_gincr:N \g_szf_author_int

    \seq_gput_right:Nx
      \g_szf_author_order_seq
      { \int_use:N \g_szf_author_int }

    \prop_gput:Nxn
      \g_szf_author_prop
      { \int_use:N \g_szf_author_int / name }
      {#2}

    \prop_gput:NxV
      \g_szf_author_prop
      { \int_use:N \g_szf_author_int / affiliations }
      \l_szf_author_affiliations_clist

    \prop_gput:NxV
      \g_szf_author_prop
      { \int_use:N \g_szf_author_int / email }
      \l_szf_author_email_tl

    \bool_if:NTF \l_szf_author_corresponding_bool
      {
        \prop_gput:Nxn
          \g_szf_author_prop
          { \int_use:N \g_szf_author_int / corresponding }
          { true }
      }
      {
        \prop_gput:Nxn
          \g_szf_author_prop
          { \int_use:N \g_szf_author_int / corresponding }
          { false }
      }
  }

\cs_new_protected:Npn \szf_print_author:n #1
  {
    \prop_get:NxN
      \g_szf_author_prop
      { #1 / name }
      \l_tmpa_tl

    \tl_use:N \l_tmpa_tl

    \prop_get:NxN
      \g_szf_author_prop
      { #1 / affiliations }
      \l_tmpa_tl

    \tl_if_blank:VF \l_tmpa_tl
      {
        \clist_set:NV \l_tmpa_clist \l_tmpa_tl
        \textsuperscript{
          \clist_use:Nn \l_tmpa_clist { , }
        }
      }

    \prop_get:NxN
      \g_szf_author_prop
      { #1 / corresponding }
      \l_tmpa_tl

    \tl_if_eq:NnT \l_tmpa_tl { true }
      {
        \textsuperscript{*}
      }
  }

\prop_new:N \l_szf_used_affiliation_prop

\cs_new_protected:Npn \szf_mark_author_affiliations:n #1
  {
    \prop_get:NxN
      \g_szf_author_prop
      { #1 / affiliations }
      \l_tmpa_tl

    \tl_if_blank:VF \l_tmpa_tl
      {
        \clist_set:NV \l_tmpa_clist \l_tmpa_tl

        \clist_map_inline:Nn \l_tmpa_clist
          {
            \prop_put:Nnn
              \l_szf_used_affiliation_prop
              {##1}
              { }
          }
      }
  }

\cs_new_protected:Npn \szf_warn_unused_affiliations:
  {
    \seq_map_inline:Nn \g_szf_affiliation_order_seq
      {
        \prop_if_in:NnF
          \l_szf_used_affiliation_prop
          {##1}
          {
            \ClassWarning{szf}
              {Affiliation~`##1'~is~defined~but~not~used~by~any~author}
          }
      }
  }

\cs_new_protected:Npn \szf_validate_author:n #1
  {
    \prop_get:NxN
      \g_szf_author_prop
      { #1 / affiliations }
      \l_tmpa_tl

    \tl_if_blank:VF \l_tmpa_tl
      {
        \clist_set:NV \l_tmpa_clist \l_tmpa_tl

        \clist_map_inline:Nn \l_tmpa_clist
          {
            \prop_if_in:NnF
              \g_szf_affiliation_prop
              {##1}
              {
                \ClassError{szf}
                  {Author~#1~references~undefined~affiliation~`##1'}
                  {Define~the~affiliation~with~
                   \string\affiliation[##1]{...}}
              }
          }
      }
  }

\cs_new_protected:Npn \szf_validate_authors:
  {
    \prop_clear:N \l_szf_used_affiliation_prop

    \seq_map_inline:Nn \g_szf_author_order_seq
      {
        \szf_validate_author:n {##1}
        \szf_mark_author_affiliations:n {##1}
      }

    \szf_warn_unused_affiliations:
  }

\cs_new_eq:NN
  \szf@validateauthors
  \szf_validate_authors:

\cs_new_protected:Npn \szf_print_authors:
  {
    \seq_map_inline:Nn \g_szf_author_order_seq
      {
        \szf_print_author:n {##1}
        \quad
      }
  }

\cs_new_protected:Npn \szf_print_correspondence:
  {
    \bool_set_false:N \l_tmpa_bool

    \seq_map_inline:Nn \g_szf_author_order_seq
      {
        \prop_get:NxN
          \g_szf_author_prop
          { ##1 / corresponding }
          \l_tmpa_tl

        \tl_if_eq:NnT \l_tmpa_tl { true }
          {
            \bool_if:NF \l_tmpa_bool
              {
                \vspace{0.5em}
                \par
                \small
                \textsuperscript{*}
                \bool_set_true:N \l_tmpa_bool
              }

            \prop_get:NxN
              \g_szf_author_prop
              { ##1 / name }
              \l_tmpa_tl

            \tl_use:N \l_tmpa_tl

            \prop_get:NxN
              \g_szf_author_prop
              { ##1 / email }
              \l_tmpa_tl

            \tl_if_blank:VF \l_tmpa_tl
              {
                :~\tl_use:N \l_tmpa_tl
              }

            \quad
          }
      }

    \bool_if:NT \l_tmpa_bool
      {
        \par
      }
  }

\cs_new_eq:NN \szf@printauthors
  \szf_print_authors:

\cs_new_eq:NN \szf@printcorrespondence
  \szf_print_correspondence:

\ExplSyntaxOff

% --- Affiliations storage and interface ---

\ExplSyntaxOn

\prop_new:N \g_szf_affiliation_prop
\seq_new:N  \g_szf_affiliation_order_seq

\NewDocumentCommand \affiliation { O{} m }
  {
    \tl_if_blank:nTF {#1}
      {
        \ClassError{szf}
          {Affiliation~identifier~is~missing}
          {Use~\string\affiliation[<id>]{<text>}}
      }
      {
        \prop_if_in:NnTF \g_szf_affiliation_prop {#1}
          {
            \ClassError{szf}
              {Affiliation~`#1'~is~already~defined}
              {Use~a~unique~affiliation~identifier}
          }
          {
            \prop_gput:Nnn \g_szf_affiliation_prop {#1} {#2}
            \seq_gput_right:Nn \g_szf_affiliation_order_seq {#1}
          }
      }
  }

\cs_new_protected:Npn \szf_print_affiliations:
  {
    \seq_map_inline:Nn \g_szf_affiliation_order_seq
      {
        \prop_get:NnN
          \g_szf_affiliation_prop
          {##1}
          \l_tmpa_tl

        \textsuperscript{##1}
        \tl_use:N \l_tmpa_tl
        \par
      }
  }

\cs_new_eq:NN
  \szf@printaffiliations
  \szf_print_affiliations:

\ExplSyntaxOff

% --- Common metadata helpers ---

\ExplSyntaxOn

\cs_new_protected:Npn \szf_metadata_store:Nnn #1#2#3
  {
    \str_case:nnF {#2}
      {
        { russian }
          {
            \prop_gput:Nnn #1 { russian } {#3}
          }
        { english }
          {
            \prop_gput:Nnn #1 { english } {#3}
          }
      }
      {
        \ClassError{szf}
          {Unknown~metadata~language~`#2'}
          {Use~russian~or~english}
      }
  }

\cs_generate_variant:Nn \szf_metadata_store:Nnn { NVn }

\ExplSyntaxOff

% Article metadata

% --- Title storage and interface ---

\ExplSyntaxOn

\prop_new:N \g_szf_title_prop

\cs_new_protected:Npn \szf_title_store:nn #1#2
  {
    \szf_metadata_store:Nnn
      \g_szf_title_prop
      {#1}
      {#2}

    \tl_if_eq:VnT \g_szf_language_tl {#1}
      {
        \gdef\@title{#2}
      }
  }

\cs_generate_variant:Nn \szf_title_store:nn { Vn }

\RenewDocumentCommand \title { O{} m }
  {
    \tl_if_blank:nTF {#1}
      {
        \szf_title_store:Vn \g_szf_language_tl {#2}
      }
      {
        \szf_title_store:nn {#1} {#2}
      }
  }

\cs_new_protected:Npn \szf_print_title:
  {
    \prop_get:NVNTF
      \g_szf_title_prop
      \g_szf_language_tl
      \l_tmpa_tl
      {
        \tl_use:N \l_tmpa_tl
      }
      {
        \ClassWarning{szf}
          {Title~for~language~`\tl_use:N \g_szf_language_tl'~is~not~specified}
      }
  }

\cs_new_eq:NN \szf@printtitle \szf_print_title:

\ExplSyntaxOff


% --- UDC storage and interface ---

\ExplSyntaxOn

\seq_new:N \g_szf_udc_seq

\NewDocumentCommand \udc { m }
  {
    \seq_gput_right:Nn \g_szf_udc_seq {#1}
  }

\cs_new_protected:Npn \szf_print_udc:
  {
    \seq_if_empty:NF \g_szf_udc_seq
      {
        УДК~
        \seq_use:Nn \g_szf_udc_seq {;~}
      }
  }

\cs_new_eq:NN \szf@printudc \szf_print_udc:

\ExplSyntaxOff

% --- Abstract and keywords storage and interface ---

\ExplSyntaxOn

\prop_new:N \g_szf_abstract_prop
\prop_new:N \g_szf_keywords_prop

\cs_new_protected:Npn \szf_abstract_store:nn #1#2
  {
    \szf_metadata_store:Nnn
      \g_szf_abstract_prop
      {#1}
      {#2}
  }

\cs_new_protected:Npn \szf_keywords_store:nn #1#2
  {
    \szf_metadata_store:Nnn
      \g_szf_keywords_prop
      {#1}
      {#2}
  }

\cs_generate_variant:Nn \szf_abstract_store:nn { Vn }
\cs_generate_variant:Nn \szf_keywords_store:nn { Vn }

\RenewDocumentEnvironment { abstract } { O{} +b }
  {
    \tl_if_blank:nTF {#1}
      {
        \szf_abstract_store:Vn \g_szf_language_tl {#2}
      }
      {
        \szf_abstract_store:nn {#1} {#2}
      }
  }
  {}

\NewDocumentCommand \keywords { O{} m }
  {
    \tl_if_blank:nTF {#1}
      {
        \szf_keywords_store:Vn \g_szf_language_tl {#2}
      }
      {
        \szf_keywords_store:nn {#1} {#2}
      }
  }

\cs_new_protected:Npn \szf_print_abstract:
  {
    \prop_get:NVNT
      \g_szf_abstract_prop
      \g_szf_language_tl
      \l_tmpa_tl
      {
        \vspace{1em}
        \begin{minipage}{\textwidth}
          \small
          \textbf{\szf@abstractname.~}
          \tl_use:N \l_tmpa_tl
        \end{minipage}
      }
  }

\cs_new_protected:Npn \szf_print_keywords:
  {
    \prop_get:NVNT
      \g_szf_keywords_prop
      \g_szf_language_tl
      \l_tmpa_tl
      {
        \vspace{0.5em}
        \begin{minipage}{\textwidth}
          \small
          \textbf{\szf@keywordsname{}:~}
          \tl_use:N \l_tmpa_tl
        \end{minipage}
      }
  }

\cs_new_eq:NN \szf@printabstract \szf_print_abstract:
\cs_new_eq:NN \szf@printkeywords \szf_print_keywords:

\ExplSyntaxOff

% MakeTitle

\renewcommand\@maketitle{%
	\begin{center}

		{\small\raggedright\szf@printudc\par}

		{\Large\bfseries \szf@printtitle\par}
		
		\vspace{1em}

		\szf@validateauthors
		
		{\normalsize
			\szf@printauthors
			\par
		}

		\vspace{0.8em}

		{\small
			\szf@printaffiliations
		}

		\szf@printcorrespondence
		
		\szf@printabstract
		
		\szf@printkeywords

	\end{center}
	
	\vspace{1em}
}

% Нумерация строк в режиме рецензирования
\if@szfreview
\RequirePackage{lineno}
\AddToHook{begindocument}{\linenumbers}
\fi

% Общая геометрия журнала
\setlength{\textwidth}{175mm}
\setlength{\textheight}{240mm}

\setlength{\oddsidemargin}{%
	\dimexpr(\paperwidth-\textwidth)/2-1in\relax
}
\setlength{\evensidemargin}{\oddsidemargin}

% Различия режимов
\if@szfreview
% review-specific settings
\else
\setlength{\columnsep}{6mm}
\fi

\setlength{\headheight}{0pt}
\setlength{\headsep}{0pt}
\setlength{\topmargin}{%
	\dimexpr(\paperheight-\textheight)/2-1in\relax
}