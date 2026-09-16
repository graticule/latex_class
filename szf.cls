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

% Авторы

\let\szf@authors\@empty
\let\szf@correspondence\@empty

\DeclareKeys[szf/author]
{
	affiliation.store = \szf@author@affiliation,
	email.store       = \szf@author@email,
	corresponding.if  = @szf@author@corresponding
}

\RenewDocumentCommand{\author}{O{} m}{%
	\g@addto@macro\szf@authors{%
		\szf@authoritem{#2}{#1}%
	}%
}

\newcommand\szf@authoritem[2]{%
	\begingroup
	\def\szf@author@affiliation{}%
	\def\szf@author@email{}%
	\@szf@author@correspondingfalse
	
	\SetKeys[szf/author]{#2}%
	
	\if@szf@author@corresponding
	\g@addto@macro\szf@correspondence{%
		\szf@correspondenceitem{#1}{#2}%
	}%
	\fi
	
	#1%
	\ifx\szf@author@affiliation\@empty
	\else
		\textsuperscript{\szf@author@affiliation}%
	\fi
	\if@szf@author@corresponding
		\textsuperscript{*}%
	\fi
	\quad
	\endgroup
}

\newcommand\szf@correspondenceitem[2]{%
	\begingroup
	\def\szf@author@email{}%
	\SetKeys[szf/author]{#2}%
	#1%
	\ifx\szf@author@email\@empty
	\else
	: \szf@author@email
	\fi
	\endgroup
}

% Аффилиации

\let\szf@affiliations\@empty

\NewDocumentCommand{\affiliation}{O{} m}{%
	\g@addto@macro\szf@affiliations{%
		\szf@affiliationitem{#1}{#2}%
	}%
}

\newcommand\szf@affiliationitem[2]{%
	\textsuperscript{#1}#2\par
}

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
		
		{\normalsize
			\szf@authors
			\par
		}
		
		\vspace{0.8em}
		
		{\small
			\szf@affiliations
		}
		
		\ifx\szf@correspondence\@empty
		\else
		\vspace{0.5em}
		{\small
			\textsuperscript{*}\szf@correspondence\par
		}
		\fi
		
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