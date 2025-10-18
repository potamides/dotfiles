#!/usr/bin/env python

###############################################################################
#   Filter the arXiv daily title/abstract distribution based on keywords of   #
#                                  interest.                                  #
###############################################################################

from re import MULTILINE, search
from sys import stdin

PATTERN = "^To: .* daily title/abstract distribution <rabble@arXiv.org>$"
KEYWORDS = [
    "code generation",
    "document understanding",
    "graphics program",
    "inverse graphics",
    "procedural material",
    "program synthesis",
    "LaTeX",
    "vector graphics",
    "LMM",
    "MLLM",
    "multimodal",
    "optical character recognition"
    "perceptual similarity",
    "poetry",
    "scientific document"
    "scientific figure"
    "TikZ",
    "vectorization",
    "vision language model",
    "VLLM",
    "VLM",
]


class ArxivMail:
    sep = 78 * "-" + "\n"
    header_sep = 2 * sep
    footer = 13 * "%%%---"

    def __init__(self, mail=None, header=None, papers=None, filtered=0):
        self.filtered = filtered
        if mail is not None:
            self.header, _, self.papers = mail.rpartition(self.header_sep)
            self.papers = self.papers.rstrip(self.footer).split(self.sep)
        self.header = header or self.header
        self.papers = papers or self.papers

    def filter(self, keywords):
        filtered_papers = [
            paper
            for paper in self.papers
            if any(key.lower() in " ".join(paper.split()).lower() for key in keywords)
        ]
        return ArxivMail(
            header=self.header,
            papers=filtered_papers,
            filtered=self.filtered + len(self.papers) - len(filtered_papers),
        )

    def __repr__(self):
        papers = self.sep.join(self.papers)
        header = self.sep.join([self.header, f"Filtered {self.filtered} papers.\n"])
        return "".join([header, self.header_sep, papers, self.footer])


if __name__ == "__main__":
    if search(PATTERN, mail := stdin.read(), MULTILINE):
        print(ArxivMail(mail).filter(KEYWORDS))
    else:
        print(mail)
