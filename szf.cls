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

% Article metadata
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

% Аннотация и ключевые слова

\let\szf@abstract\@empty
\let\szf@keywords\@empty

\RenewDocumentEnvironment{abstract}{+b}
{%
	\gdef\szf@abstract{#1}%
}
{}

\NewDocumentCommand{\keywords}{m}{%
	\gdef\szf@keywords{#1}%
}

% MakeTitle

\renewcommand\@maketitle{%
	\begin{center}

		{\small\raggedright\szf@printudc\par}

		{\Large\bfseries \@title\par}
		
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
		
		\ifx\szf@abstract\@empty
		\else
		\vspace{1em}
		\begin{minipage}{\textwidth}
			\small
			\textbf{\szf@abstractname. }\szf@abstract
		\end{minipage}
		\fi
		
		\ifx\szf@keywords\@empty
		\else
		\vspace{0.5em}
		\begin{minipage}{\textwidth}
			\small
			\textbf{\szf@keywordsname: }\szf@keywords
		\end{minipage}
		\fi
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