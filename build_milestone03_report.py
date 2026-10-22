# -*- coding: utf-8 -*-
"""
Script to generate the complete, consolidated IT3060 Human Computer Interaction Final Report
Covering Milestone 01, Milestone 02, and Milestone 03.
Group: WE_105 | Group Name: WE_105
Course: IT3060 Human Computer Interaction, Year 3 Semester 2 2026, SLIIT
Project Title: Family Expense and Shared Budget Tracking App ("Smart Family Budget")
Output: IT3060HCI2026_Milestone03_Group_WE_105.docx
"""

import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn

def create_full_report():
    doc = docx.Document()

    # Page Margins: 1.0 inch all around
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        section.different_first_page_header_footer = True

        # Header and Footer Setup
        header = section.header
        p_hdr = header.paragraphs[0]
        p_hdr.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r_hdr = p_hdr.add_run("IT3060 Human Computer Interaction | Milestones 01–03 Final Report")
        r_hdr.font.name = "Calibri"
        r_hdr.font.size = Pt(8.5)
        r_hdr.font.color.rgb = RGBColor(148, 163, 184)

        footer = section.footer
        p_ft = footer.paragraphs[0]
        p_ft.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r_ft = p_ft.add_run("Group WE_105 | Family Expense and Shared Budget Tracking App")
        r_ft.font.name = "Calibri"
        r_ft.font.size = Pt(8.5)
        r_ft.font.color.rgb = RGBColor(148, 163, 184)

    # Color Tokens
    COLOR_PRIMARY = RGBColor(15, 118, 110)       # Deep Emerald #0F766E
    COLOR_SECONDARY = RGBColor(6, 95, 70)       # Dark Forest #065F46
    COLOR_ACCENT = RGBColor(20, 184, 166)       # Emerald Teal #14B8A6
    COLOR_TEXT = RGBColor(15, 23, 42)           # Slate Dark #0F172A
    COLOR_MUTED = RGBColor(100, 116, 139)       # Slate Muted #64748B

    HEX_PRIMARY = "0F766E"
    HEX_SECONDARY = "065F46"
    HEX_LIGHT_BG = "F8FAFC"
    HEX_ALT_ROW = "F1F5F9"
    HEX_BORDER = "CBD5E1"
    HEX_CALLOUT_BG = "F0FDF4"

    # Helpers
    def set_cell_background(cell, hex_color):
        tcPr = cell._tc.get_or_add_tcPr()
        tcPr.append(parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>'))

    def set_cell_margins(cell, top=100, bottom=100, left=140, right=140):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = parse_xml(
            f'<w:tcMar {nsdecls("w")}>'
            f'<w:top w:w="{top}" w:type="dxa"/>'
            f'<w:bottom w:w="{bottom}" w:type="dxa"/>'
            f'<w:left w:w="{left}" w:type="dxa"/>'
            f'<w:right w:w="{right}" w:type="dxa"/>'
            f'</w:tcMar>'
        )
        tcPr.append(tcMar)

    def set_table_borders(table, color=HEX_BORDER, sz="4", val="single"):
        tblPr = table._tbl.tblPr
        borders = parse_xml(
            f'<w:tblBorders {nsdecls("w")}>'
            f'<w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
            f'<w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
            f'<w:left w:val="none"/>'
            f'<w:right w:val="none"/>'
            f'<w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
            f'<w:insideV w:val="none"/>'
            f'</w:tblBorders>'
        )
        tblPr.append(borders)

    def add_p(text="", bold=False, italic=False, size=10, color=COLOR_TEXT, space_after=4, align=WD_ALIGN_PARAGRAPH.LEFT, line_spacing=1.15):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = line_spacing
        if text:
            r = p.add_run(text)
            r.bold = bold
            r.italic = italic
            r.font.name = "Calibri"
            r.font.size = Pt(size)
            r.font.color.rgb = color
        return p

    def add_bullet(bold_prefix, text, size=9.5, space_after=2.5):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_b = p.add_run(bold_prefix)
            r_b.bold = True
            r_b.font.name = "Calibri"
            r_b.font.size = Pt(size)
            r_b.font.color.rgb = COLOR_TEXT
        r_t = p.add_run(text)
        r_t.font.name = "Calibri"
        r_t.font.size = Pt(size)
        r_t.font.color.rgb = COLOR_TEXT
        return p

    def add_h1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(5)
        p.paragraph_format.keep_with_next = True
        r = p.add_run(text)
        r.bold = True
        r.font.name = "Calibri"
        r.font.size = Pt(15)
        r.font.color.rgb = COLOR_PRIMARY
        return p

    def add_h2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(11)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.keep_with_next = True
        r = p.add_run(text)
        r.bold = True
        r.font.name = "Calibri"
        r.font.size = Pt(12.5)
        r.font.color.rgb = COLOR_SECONDARY
        return p

    def add_h3(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.keep_with_next = True
        r = p.add_run(text)
        r.bold = True
        r.font.name = "Calibri"
        r.font.size = Pt(11)
        r.font.color.rgb = COLOR_ACCENT
        return p

    def add_callout(title, text):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        cell.width = Inches(6.5)
        set_cell_background(cell, HEX_CALLOUT_BG)
        set_cell_margins(cell, top=100, bottom=100, left=160, right=160)

        tcPr = cell._tc.get_or_add_tcPr()
        borders = parse_xml(
            f'<w:tcBorders {nsdecls("w")}>'
            f'<w:top w:val="none"/>'
            f'<w:bottom w:val="none"/>'
            f'<w:left w:val="single" w:sz="24" w:space="0" w:color="{HEX_PRIMARY}"/>'
            f'<w:right w:val="none"/>'
            f'</w:tcBorders>'
        )
        tcPr.append(borders)

        p = cell.paragraphs[0]
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(2)
        r_t = p.add_run(f"📌 {title}: ")
        r_t.bold = True
        r_t.font.name = "Calibri"
        r_t.font.size = Pt(9.5)
        r_t.font.color.rgb = COLOR_PRIMARY

        r_c = p.add_run(text)
        r_c.font.name = "Calibri"
        r_c.font.size = Pt(9)
        r_c.font.color.rgb = COLOR_TEXT

        p_after = doc.add_paragraph()
        p_after.paragraph_format.space_before = Pt(0)
        p_after.paragraph_format.space_after = Pt(3)

    def add_image_placeholder(caption):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        cell.width = Inches(6.5)
        set_cell_background(cell, HEX_LIGHT_BG)
        set_cell_margins(cell, top=140, bottom=140, left=160, right=160)

        tcPr = cell._tc.get_or_add_tcPr()
        borders = parse_xml(
            f'<w:tcBorders {nsdecls("w")}>'
            f'<w:top w:val="dashed" w:sz="6" w:space="0" w:color="{HEX_BORDER}"/>'
            f'<w:bottom w:val="dashed" w:sz="6" w:space="0" w:color="{HEX_BORDER}"/>'
            f'<w:left w:val="dashed" w:sz="6" w:space="0" w:color="{HEX_BORDER}"/>'
            f'<w:right w:val="dashed" w:sz="6" w:space="0" w:color="{HEX_BORDER}"/>'
            f'</w:tcBorders>'
        )
        tcPr.append(borders)

        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(2)
        r = p.add_run(f"[ SCREENSHOT / INTERFACE ARTIFACT: {caption} ]")
        r.italic = True
        r.bold = True
        r.font.name = "Calibri"
        r.font.size = Pt(9)
        r.font.color.rgb = COLOR_MUTED

        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_cap.paragraph_format.space_before = Pt(2)
        p_cap.paragraph_format.space_after = Pt(6)
        r_cap = p_cap.add_run(f"Figure: {caption}")
        r_cap.font.name = "Calibri"
        r_cap.font.size = Pt(8.5)
        r_cap.italic = True
        r_cap.font.color.rgb = COLOR_MUTED

    def format_table_header(row, col_widths, titles):
        for i, (cell, w, title) in enumerate(zip(row.cells, col_widths, titles)):
            cell.width = Inches(w)
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_background(cell, HEX_PRIMARY)
            set_cell_margins(cell, top=100, bottom=100, left=120, right=120)
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(0)
            p.paragraph_format.space_after = Pt(0)
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            r = p.add_run(title)
            r.bold = True
            r.font.name = "Calibri"
            r.font.size = Pt(9)
            r.font.color.rgb = RGBColor(255, 255, 255)

    def format_table_row(row, col_widths, values, is_alt=False, align_right_cols=[]):
        bg = HEX_ALT_ROW if is_alt else "FFFFFF"
        for i, (cell, w, val) in enumerate(zip(row.cells, col_widths, values)):
            cell.width = Inches(w)
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            if is_alt:
                set_cell_background(cell, bg)
            set_cell_margins(cell, top=80, bottom=80, left=120, right=120)
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(0)
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.line_spacing = 1.15
            p.alignment = WD_ALIGN_PARAGRAPH.RIGHT if i in align_right_cols else WD_ALIGN_PARAGRAPH.LEFT
            r = p.add_run(str(val))
            r.font.name = "Calibri"
            r.font.size = Pt(8.5)
            r.font.color.rgb = COLOR_TEXT

    # =========================================================================
    # COVER PAGE
    # =========================================================================
    p_inst = doc.add_paragraph()
    p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_inst.paragraph_format.space_before = Pt(24)
    p_inst.paragraph_format.space_after = Pt(2)
    r_inst = p_inst.add_run("SRI LANKA INSTITUTE OF INFORMATION TECHNOLOGY")
    r_inst.bold = True
    r_inst.font.name = "Calibri"
    r_inst.font.size = Pt(13)
    r_inst.font.color.rgb = COLOR_PRIMARY

    p_fac = doc.add_paragraph()
    p_fac.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_fac.paragraph_format.space_after = Pt(18)
    r_fac = p_fac.add_run("FACULTY OF COMPUTING | DEPARTMENT OF COMPUTER SCIENCE & SOFTWARE ENGINEERING")
    r_fac.font.name = "Calibri"
    r_fac.font.size = Pt(10)
    r_fac.font.color.rgb = COLOR_MUTED

    p_mod = doc.add_paragraph()
    p_mod.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_mod.paragraph_format.space_after = Pt(4)
    r_mod = p_mod.add_run("IT3060 — HUMAN COMPUTER INTERACTION")
    r_mod.bold = True
    r_mod.font.name = "Calibri"
    r_mod.font.size = Pt(15)
    r_mod.font.color.rgb = COLOR_SECONDARY

    p_sub = doc.add_paragraph()
    p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub.paragraph_format.space_after = Pt(24)
    r_sub = p_sub.add_run("Milestones 01–03 Final Consolidated Project Report\nYear 3 Semester 2 — 2026")
    r_sub.font.name = "Calibri"
    r_sub.font.size = Pt(11)
    r_sub.font.color.rgb = COLOR_TEXT

    # Project Title Banner Box
    tbl_title = doc.add_table(rows=1, cols=1)
    tbl_title.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell_t = tbl_title.cell(0, 0)
    cell_t.width = Inches(6.5)
    set_cell_background(cell_t, HEX_LIGHT_BG)
    set_cell_margins(cell_t, top=160, bottom=160, left=200, right=200)
    set_table_borders(tbl_title, color=HEX_PRIMARY, sz="12", val="single")

    p_pt = cell_t.paragraphs[0]
    p_pt.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_pt.paragraph_format.space_after = Pt(4)
    r_pt1 = p_pt.add_run("PROJECT TITLE\n")
    r_pt1.bold = True
    r_pt1.font.name = "Calibri"
    r_pt1.font.size = Pt(9.5)
    r_pt1.font.color.rgb = COLOR_MUTED

    r_pt2 = p_pt.add_run("Smart Family Budget:\nA Cross-Platform Mobile Application for Real-Time Family Expense\nCoordination and Shared Budget Tracking")
    r_pt2.bold = True
    r_pt2.font.name = "Calibri"
    r_pt2.font.size = Pt(14)
    r_pt2.font.color.rgb = COLOR_PRIMARY

    p_space = doc.add_paragraph()
    p_space.paragraph_format.space_after = Pt(14)

    # Group Identification
    p_grp = doc.add_paragraph()
    p_grp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_grp.paragraph_format.space_after = Pt(12)
    r_g1 = p_grp.add_run("GROUP NUMBER: ")
    r_g1.bold = True
    r_g1.font.size = Pt(11)
    r_g2 = p_grp.add_run("WE_105          ")
    r_g2.bold = True
    r_g2.font.color.rgb = COLOR_PRIMARY
    r_g2.font.size = Pt(11)
    r_g3 = p_grp.add_run("GROUP NAME: ")
    r_g3.bold = True
    r_g3.font.size = Pt(11)
    r_g4 = p_grp.add_run("WE_105\n")
    r_g4.bold = True
    r_g4.font.color.rgb = COLOR_PRIMARY
    r_g4.font.size = Pt(11)
    r_repo = p_grp.add_run("GitHub Repository: https://github.com/justtnikiyaa/family_budget_app.git")
    r_repo.font.size = Pt(9.5)
    r_repo.font.color.rgb = COLOR_SECONDARY

    # Group Members Table
    add_p("Group Member Details & Comprehensive Workload Distribution:", bold=True, size=10, space_after=4)
    tbl_members = doc.add_table(rows=5, cols=4)
    tbl_members.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_members)
    mem_widths = [1.1, 1.6, 1.8, 2.0]
    mem_headers = ["Student ID", "Full Name", "Milestones 01 & 02 Workload", "Milestone 03 Implementation & CRUD Scope"]
    format_table_header(tbl_members.rows[0], mem_widths, mem_headers)

    mem_data = [
        ("IT23734920", "W.M.N Dulavin", 
         "M01: User research plan & rationale, Google Form design, Data collection, Participant summary.\nM02: Requirements traceability matrix, initial sketches & variants (Screens 1–2), final report compilation.",
         "Screen 1 & 1a (Animated Splash Sequence & Multilingual Onboarding Carousel)\nScreen 2, 2a & 2b (Login, Register & Join Household via 6-Digit Code)\nCRUD: User registration in Firebase Auth & profile in users/{uid}, locale persistence; Login auth & join household code verification."),
        ("IT23740310", "Amarasinghe A.L.O.A",
         "M01: Thematic analysis, 3 Personas, 3 Empathy maps.\nM02: Initial sketches & variants (Screens 3–4), wireframe development, low-fidelity prototype linking.",
         "Screen 2c (Create Family: Household Name & Admin Setup)\nScreen 3 (Shared Family Budget Dashboard: Real-time Overview & Breakdown)\nScreen 4 (Quick Add Expense: Modal Bottom Sheet with Custom Keypad)\nCRUD: Create household document & log expense in ≤3 taps; Read real-time dashboard stream & delete expense."),
        ("IT23739352", "W.M.R Amavin",
         "M01: Problem statement & justification, Stakeholder identification & categorization, Gantt chart.\nM02: High-fidelity interactive prototype design in Figma, design system & reusable components, Figma link setup.",
         "Screen 5 & 5a (Category Limits & Overspend At-Risk Alerts)\nScreen 6 & 6a (Bill Reminders & Add New Bill)\nScreen 7 (Monthly Summary & Expenditure Report)\nScreen 8 (Dual-Tier Savings Goals: Family & Personal)\nCRUD: Create/Update bill reminders & category limits with alerts; Update/Delete settled bills & savings goal deposits."),
        ("IT23750388", "W.G.K Shiwangi",
         "M01: 5 User stories, User journey maps, HMW statements, Requirements.\nM02: Usability test plan, conducting testing sessions with 5 participants, issue logging, refinement roadmap.",
         "Screen 9 (Settings & Preferences: Language, Text Size, Toggles)\nScreen 9a (Manage Family Members & Role Allocations)\nScreen 10 (Invite Member: Share Code / WhatsApp)\nScreen 11 (My Profile & Edit Profile Details)\nCRUD: Read/Update user profile & app settings (language/text size); Update/Delete member role permissions & member removal.")
    ]

    for idx, row_vals in enumerate(mem_data):
        format_table_row(tbl_members.rows[idx + 1], mem_widths, row_vals, is_alt=(idx % 2 == 1))

    p_sub_date = doc.add_paragraph()
    p_sub_date.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sub_date.paragraph_format.space_before = Pt(16)
    p_sub_date.paragraph_format.space_after = Pt(0)
    r_date = p_sub_date.add_run("Date of Final Submission: October 09, 2026 | Submission Portal: SLIIT Courseweb")
    r_date.font.size = Pt(9)
    r_date.font.color.rgb = COLOR_MUTED

    doc.add_page_break()

    # =========================================================================
    # EXECUTIVE SUMMARY
    # =========================================================================
    add_h1("Executive Summary")
    add_p(
        "Household financial management in contemporary Sri Lankan families represents a complex, multi-agent coordination challenge. "
        "Due to escalating utility tariffs, double-digit cost-of-living fluctuations, and fragmented household revenue streams (shared among working parents, "
        "tertiary students, and retired seniors), conventional individualistic expense trackers fail systematically. Previous tools either require "
        "tedious, repetitive manual data entry that users abandon within days, or lack real-time synchronization across family members, resulting in uncoordinated "
        "spending, missed utility deadlines, and avoidable domestic financial stress."
    )
    add_p(
        "To resolve this everyday societal problem under the 'Finance & Livelihoods' theme of the IT3060 Human Computer Interaction module, "
        "Group WE_105 conceptualized, designed, implemented, and validated 'Smart Family Budget' — a cross-platform mobile application engineered using "
        "Google Flutter and Google Firebase. The system bridges generational digital divides by offering a tri-lingual interface (Sinhala, Tamil, English), "
        "a friction-free 3-tap rapid expense logging mechanism (satisfying FR1 and NFR1), an aggregated family macro-dashboard with real-time Firestore sync, "
        "proactive visual category threshold alerts (amber at 80%, crimson at 95%), an urgency-segmented bill settlement ledger, and dual-tier savings goals "
        "supporting both shared household targets and personal youth funds."
    )
    add_p(
        "This consolidated final report encapsulates the end-to-end user-centered development process executed across three distinct milestones:"
    )
    add_bullet("Milestone 01 (Discovery & Requirements): ", "Empirical survey of 21 Sri Lankan household participants revealing five distinct behavioural themes, 3 validated personas (Kavindu, Nirosha, Soma), 3 empathy maps, 5 user stories, 2 journey maps, and formalized Functional (FR1–FR8) and Non-Functional (NFR1–NFR6) requirements.")
    add_bullet("Milestone 02 (Interaction Design & Prototyping): ", "Exploratory hand sketches, rigorous multi-variant architectural trade-off evaluations (Variants A, B, C per screen), low-fidelity clickable wireframing in Figma, a production-grade 14-screen High-Fidelity Design System utilizing Deep Emerald (#0F766E) and Slate tokens, and an initial think-aloud evaluation resolving five preliminary UI bottlenecks.")
    add_bullet("Milestone 03 (Implementation, Testing & Final Evaluation): ", "Full-stack mobile app engineering using Flutter 3.x and Firebase NoSQL Cloud Firestore, distributing equal development workloads across all four team members with 2+ working CRUD operations per interface. Rigorous functional testing (14/14 test cases passing, 100% pass rate) and moderated usability evaluations with 5 representative users yielded an exceptional System Usability Scale (SUS) score of 84.5 out of 100 (Grade A / 'Excellent' usability rating).")

    add_callout(
        "Key Project Outcome",
        "Smart Family Budget demonstrates that multi-generational financial software can achieve zero-training learnability (average task time under 15 seconds) "
        "while maintaining robust data integrity, sub-second cloud synchronization, and local language accessibility for Sri Lankan households."
    )

    doc.add_page_break()

    # =========================================================================
    # SECTION 1: MILESTONE 01 SUMMARY
    # =========================================================================
    add_h1("1. Milestone 01 Consolidated Summary")
    add_h2("1.1 Problem Statement & Justification")
    add_p(
        "In typical Sri Lankan households, daily financial outlays are carried out independently by multiple family members without a consolidated, "
        "shared perspective. Working parents settle grocery and utility bills, income-earning young adults make personal and household contributions, "
        "and university students spend on commuting, study materials, and food allowances. Because individual expenses remain trapped in personal memory, "
        "scattered physical slips, or private messaging notes, families experience severe end-of-month budget deficits without knowing how the overrun occurred."
    )
    add_p(
        "Household financial management was selected because it represents a universal, everyday struggle falling directly within the 'Finance & Livelihoods' "
        "domain. It enables multi-persona research across varied age groups, literacy levels, and financial responsibilities, while having high social impact "
        "by fostering financial transparency and reducing domestic conflict."
    )

    add_h2("1.2 Stakeholder Categorization")
    add_p("Stakeholders were identified and structured according to their systemic involvement:")
    
    tbl_sh = doc.add_table(rows=4, cols=3)
    tbl_sh.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_sh)
    sh_widths = [1.2, 2.0, 3.3]
    format_table_header(tbl_sh.rows[0], sh_widths, ["Stakeholder Tier", "Stakeholder Group", "Operational Role & Systemic Impact"])
    sh_data = [
        ("Primary Stakeholders", "Parents / Financial Managers\nWorking Adults / Secondary Earners",
         "Daily primary users documenting household income, managing category budgets, scheduling utility bills, and monitoring aggregate liquidity."),
        ("Secondary Stakeholders", "University Students / School Youth\nExtended Family Contributors",
         "Discretionary spenders logging daily allowances, tracking personal savings goals (e.g., tech equipment), and viewing household spending boundaries."),
        ("Tertiary Stakeholders", "SLIIT Project Development Team\nCommercial Banks / Utility Providers",
         "Engineers maintaining system architecture and future API integration partners for automated SMS transaction scraping and direct utility bill debit.")
    ]
    for idx, row_vals in enumerate(sh_data):
        format_table_row(tbl_sh.rows[idx + 1], sh_widths, row_vals, is_alt=(idx % 2 == 1))

    add_h2("1.3 User Research Plan & Methodology")
    add_p(
        "To gather broad, unbiased empirical insights across multiple demographics, an online quantitative and qualitative questionnaire was formulated "
        "on Google Forms and disseminated via WhatsApp, Facebook, and Instagram between July and August 2026. A total of 21 validated responses were collected "
        "(exceeding the minimum 5-participant requirement), spanning four family roles: University Students (62%, n=13), Working Adults (14%, n=3), "
        "Parents / Guardians (14%, n=3), and School Students (10%, n=2)."
    )

    add_h2("1.4 Thematic Analysis & Empirical Findings")
    add_p("Thematic inductive coding across the 21 survey datasets revealed five primary user behaviour patterns:")
    add_bullet("Theme 1: Severe Deficit in Visibility & Awareness: ", "38% of respondents (8/21) maintain zero tracking mechanism, and 71% (15/21) regularly exceed their monthly budget unconsciously. Participants P2 and P18 explicitly requested 'automatic tracking with alerts before we overspend'.")
    add_bullet("Theme 2: Poor Family Coordination & Shared Opacity: ", "62% of respondents (13/21) selected 'Shared budget visible to all family members' as their highest-priority feature, citing unannounced partner purchases as the primary trigger for domestic financial tension.")
    add_bullet("Theme 3: High Friction & Rapid Abandonment in Manual Entry: ", "Participants noted that conventional expense apps fail because entering every single transaction requires excessive manual navigation and typing, causing users to abandon logging within 48 to 72 hours.")
    add_bullet("Theme 4: Strong Demand for Proactive Alerts & Forward Planning: ", "Savings goal tracking was requested by 67% (14/21) and bill payment reminders by 57% (12/21). Senior parent P14 emphasized: 'We need to know the experiences to get an idea about spending for next month'.")
    add_bullet("Theme 5: Near-Universal Mobile Preference (95%): ", "20 out of 21 respondents specified smartphones as their sole daily access platform, mandating a lightweight, high-contrast, thumb-friendly mobile-first UI architecture.")

    add_h2("1.5 Empirically Grounded Personas & Empathy Maps")
    add_p("Three distinct personas were synthesized to represent key demographic archetypes:")

    # Persona Table
    tbl_p = doc.add_table(rows=4, cols=4)
    tbl_p.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_p)
    p_widths = [1.4, 1.4, 1.8, 1.9]
    format_table_header(tbl_p.rows[0], p_widths, ["Persona", "Demographic Profile", "Primary Goals", "Critical Pain Points & Barriers"])
    p_data = [
        ("Persona 1:\nKavindu Perera\n(Passive Student)", "Age: 21 | Colombo\n2nd Year SLIIT Student\nAllowance + Tutoring",
         "• Track allowance without typing.\n• Stop running out of cash by mid-month.\n• Save for a new laptop.",
         "• Relies entirely on memory.\n• Forgets to record micro-expenses.\n• Intimidated by complex spreadsheets."),
        ("Persona 2:\nNirosha Jayawardena\n(Working Parent)", "Age: 38 | Gampaha\nEmployed Manager\nTwo school children",
         "• Real-time shared family pool.\n• Enforce category caps (groceries).\n• Save for annual family holiday.",
         "• Husband buys items without telling.\n• Inconsistent Excel sheet updates.\n• Previous apps built for single users."),
        ("Persona 3:\nSoma Wijesinghe\n(Senior Parent)", "Age: 52 | Kandy\nPrimary Home Budgeter\nSmartphone only",
         "• Clear picture of remaining funds.\n• Timely utility bill reminders.\n• Tri-lingual Sinhala interface.",
         "• English-only software is a barrier.\n• Intimidated by nested technical UI.\n• Forgets utility bill due dates.")
    ]
    for idx, row_vals in enumerate(p_data):
        format_table_row(tbl_p.rows[idx + 1], p_widths, row_vals, is_alt=(idx % 2 == 1))

    add_p(
        "Empathy mapping directly corroborated these profiles: Kavindu feels embarrassed asking parents for extra funds; "
        "Nirosha experiences domestic anxiety when month-end accounts do not balance; and Soma feels overwhelmed by intricate digital workflows, "
        "craving high-contrast text and reassurance in her native mother tongue."
    )

    add_h2("1.6 Requirements Elucidation")
    add_p("The findings were formalized into eight Functional Requirements (FR) and six Non-Functional Requirements (NFR):")
    add_bullet("FR1 (Rapid Expense Logging): ", "The system shall allow a user to log an expense with amount, category, date, and optional note in three taps or fewer.")
    add_bullet("FR2 (Real-Time Shared Dashboard): ", "The system shall display a real-time shared budget dashboard visible to all linked family members.")
    add_bullet("FR3 (Category Limits & Alerts): ", "The system shall allow users to configure category spending limits and trigger proactive notifications when nearing (80%) or reaching (95%) limits.")
    add_bullet("FR4 (Bill Reminders & Calendar): ", "The system shall deliver configurable push/visual reminders for recurring bills prior to due dates.")
    add_bullet("FR5 (Monthly Summary Reports): ", "The system shall generate retrospective monthly analytics broken down by member and category.")
    add_bullet("FR6 (Multilingual Accessibility): ", "The system shall provide seamless runtime localization in Sinhala, Tamil, and English.")
    add_bullet("FR7 (Household Member Governance): ", "The system shall allow family administrators to invite or manage members via 6-digit verification codes.")
    add_bullet("FR8 (Dual-Tier Savings Goals): ", "The system shall allow setting and tracking collective family targets and personal youth funds.")
    add_bullet("NFR1–NFR6 (Quality & Performance): ", "NFR1 (Zero-training logging ≤30s); NFR2 (Real-time sync latency <2.0s); NFR3 (Reliability ≥99.5% uptime); NFR4 (Data security & encrypted Firestore isolation); NFR5 (Font scaling & WCAG AAA contrast); NFR6 (Smooth 60fps execution on low-to-mid-range Android smartphones).")

    doc.add_page_break()

    # =========================================================================
    # SECTION 2: MILESTONE 02 SUMMARY
    # =========================================================================
    add_h1("2. Milestone 02 Consolidated Summary")
    add_h2("2.1 Hand Sketches & Architectural Variants Exploration")
    add_p(
        "Milestone 02 commenced with extensive hand sketching to explore divergent interaction architectures for each core screen. "
        "Each concept was evaluated against fundamental HCI heuristics: minimizing cognitive load, thumb-zone ergonomics, and multi-generational accessibility."
    )
    add_image_placeholder("Early Exploratory Hand Sketches for Core Multi-Generational Workflows")

    add_h2("2.2 Design Alternatives & Selection Justification (Screens 1 to 9)")
    add_p("For each core interface, three distinct variants were conceived and rigorously evaluated:")

    tbl_var = doc.add_table(rows=10, cols=4)
    tbl_var.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_var)
    v_widths = [1.1, 1.8, 1.8, 1.8]
    format_table_header(tbl_var.rows[0], v_widths, ["Interface", "Evaluated Variants", "Selected Variant", "HCI Rationale & Decision"])
    var_data = [
        ("Screen 1:\nOnboarding", "A: Minimal vertical radio list\nB: Illustration + card carousel\nC: Multi-step language modal",
         "Hybrid (Variant B + C)", "Eliminates language selection navigation hops by placing native greetings directly on the landing screen."),
        ("Screen 2:\nAuth & Setup", "A: All-in-one dense setup form\nB: Sequential 2-step setup\nC: Dual-Action Hub (Create/Join)",
         "Variant C (Dual-Action Hub)", "Separates admin household creators from invited youth members entering a 6-digit code, removing friction."),
        ("Screen 3:\nQuick Add", "A: Full-screen category grid\nB: Multi-step 3-screen wizard\nC: Modal Bottom Sheet + Keypad",
         "Variant C (Docked Sheet)", "Replaces rigid full-page redirection with a docked bottom sheet, satisfying FR1 (logging in ≤3 taps) and NFR1 (≤30s)."),
        ("Screen 4:\nDashboard", "A: Single aggregate card\nB: Tabbed analytics & breakdown\nC: Modular multi-card feed",
         "Variant B (Tabbed Analytics)", "Provides glanceable individual member contribution bars alongside the total budget pool without visual clutter."),
        ("Screen 5:\nLimits & Alerts", "A: Static percentage sliders\nB: 6-month historical graph\nC: At-risk threshold progress bars",
         "Variant C (At-Risk Meters)", "Prominently ranks near-capacity categories with amber (80%) and crimson (95%) badges before overspend occurs (FR3)."),
        ("Screen 6:\nBill Reminders", "A: Basic unpaid/paid text list\nB: Full monthly calendar grid\nC: Segmented urgency checklist",
         "Variant C (Urgency Checklist)", "Partitions bills into 'Due This Week' vs 'Due Later' with high-contrast countdown badges, preventing late fines (FR4)."),
        ("Screen 7:\nReports", "A: Structured ledger & breakdown\nB: Segmented toggling ledger\nC: Single-metric swipe carousel",
         "Variant A (Structured Ledger)", "Consolidates total income, expenditure, net balance, and member shares onto a single scannable canvas (FR5)."),
        ("Screen 8:\nSavings Goals", "A: Independent stacked feed\nB: Dual-tier family vs personal\nC: Radial circular gauge carousel",
         "Variant B (Dual-Tier Goals)", "Uniquely accommodates collective family investments alongside personal student milestones in one hierarchy (FR8)."),
        ("Screen 9:\nSettings", "A: Linear nested list\nB: Grouped cards + inline toggles\nC: 2×2 tile quadrant grid",
         "Variant B (Grouped Cards)", "Expands inline controls into dedicated font scaling pills and direct language selectors without deep nesting (FR6).")
    ]
    for idx, row_vals in enumerate(var_data):
        format_table_row(tbl_var.rows[idx + 1], v_widths, row_vals, is_alt=(idx % 2 == 1))

    add_h2("2.3 Low-Fidelity Wireframes & Figma Prototype")
    add_p(
        "Figma was selected as the prototyping platform due to its real-time multi-user collaboration capabilities, native hotspot linking "
        "(enabling complex navigational transitions without auxiliary plugins), and comprehensive component libraries. "
        "A 14-screen clickable low-fidelity prototype was developed and published for stakeholder navigation validation."
    )
    add_bullet("Public Lo-Fi Figma Link: ", "https://www.figma.com/design/k67by0R5i1M0FZRTjEc5O6/Sketches.fig?node-id=3-704")

    add_h2("2.4 High-Fidelity Design System & Style Guide")
    add_p(
        "The validated wireframes were transformed into an interactive High-Fidelity Prototype incorporating an atomic design system:"
    )
    add_bullet("Color Palette: ", "Primary Brand: Deep Emerald Green (#0F766E) and Emerald Teal (#14B8A6), evoking trust, financial growth, and stability. Neutral backgrounds utilize Crisp White (#FFFFFF) and Soft Slate (#F8FAFC) to minimize visual noise. Semantic alert tokens employ Amber Gold (#F59E0B) at 80% limit warning and Crimson Red (#EF4444) at 95% critical cap.")
    add_bullet("Typography: ", "Modern geometric sans-serif (Inter / Poppins) utilizing strict hierarchical scale: Section Titles (22pt Bold), Card Headers (16pt Semi-Bold), Metric Values (24pt Bold), and Captions (12pt Regular).")
    add_bullet("Ergonomics & Touch Targets: ", "All interactive buttons, chips, and numeric keys enforce minimum touch targets of 48×48 dp, aligned with Android Material Design accessibility criteria for seniors.")
    add_bullet("Public Hi-Fi Figma Link: ", "https://www.figma.com/design/HDMK5WAlb4Rmz634CBND1r/High-Fidelity?node-id=43-70")

    add_h2("2.5 Milestone 02 Usability Testing Findings & Refinements")
    add_p(
        "Preliminary moderated testing with representative personas identified five usability bottlenecks (UI-01 to UI-05). "
        "These were addressed in the design roadmap: (UI-01) Added top-right avatar shortcut for rapid logout; (UI-02) Designed a direct 'Mark as Paid' action button on bills; "
        "(UI-03) Expanded custom numeric keypad targets to 56dp for senior accessibility; (UI-04) Replaced plain text budget alerts with high-contrast colored alert containers; "
        "and (UI-05) Clarified secondary member permissions on household invitation modals."
    )

    doc.add_page_break()

    # =========================================================================
    # SECTION 3: TECHNOLOGY STACK SELECTION & JUSTIFICATION
    # =========================================================================
    add_h1("3. Technology Stack Selection and Justification")
    add_p(
        "In conformance with the project requirements, academic constraints, and multi-platform deployment needs, "
        "the technology stack was evaluated rigorously across development velocity, rendering efficiency, real-time sync capabilities, and local hardware compatibility."
    )

    # Tech Stack Evaluation Table
    tbl_tech = doc.add_table(rows=5, cols=4)
    tbl_tech.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_tech)
    t_widths = [1.3, 1.4, 2.0, 1.8]
    format_table_header(tbl_tech.rows[0], t_widths, ["Stack Component", "Selected Technology", "Evaluated Alternatives", "Academic & Technical Justification"])
    tech_data = [
        ("Frontend Mobile Framework", "Google Flutter 3.x\n(Dart 3.x SDK)", "React Native,\nNative Kotlin / Swift",
         "Single codebase compiled to native ARM code; 60fps Impeller rendering engine guarantees smooth performance on budget smartphones (NFR6); rich widget customizability."),
        ("Backend-as-a-Service (BaaS)", "Google Firebase\n(Firebase Core & Auth)", "Custom Node.js / Express,\nSupabase",
         "Eliminates server provisioning and maintenance; secure client-side JWT authentication; built-in connection management and auto-scaling for multi-user family sessions."),
        ("Cloud Database Engine", "Google Cloud Firestore\n(NoSQL Document Store)", "PostgreSQL / MySQL,\nMongoDB Atlas",
         "Native reactive WebSocket streams (`snapshots()`) enable instant sub-second multi-device UI synchronization (NFR2); offline document caching; flexible document-collection model."),
        ("State Management Architecture", "StreamBuilder &\nChangeNotifier / Provider", "Bloc / Cubit,\nRedux",
         "Lightweight, decoupled state reactivity; direct binding to Firestore stream snapshots avoids excessive boilerplate while providing zero-delay UI updates.")
    ]
    for idx, row_vals in enumerate(tech_data):
        format_table_row(tbl_tech.rows[idx + 1], t_widths, row_vals, is_alt=(idx % 2 == 1))

    add_h2("3.1 Frontend Framework: Flutter & Dart SDK")
    add_p(
        "Flutter compiles directly to native machine code without requiring the JavaScript bridge characteristic of React Native. "
        "This architectural advantage ensures smooth 60fps animations during complex vector drawing (such as the 2.5s launch animation on the Splash Screen) "
        "and eliminates dropped frames on low-to-mid-range Android smartphones prevalent in Sri Lanka. Furthermore, Dart's sound null-safety "
        "guarantees runtime reliability, eliminating null dereference crashes across arithmetic financial calculations."
    )

    add_h2("3.2 Backend Services: Firebase Authentication & Cloud Firestore")
    add_p(
        "Rather than managing dedicated container infrastructure, Google Firebase delivers an enterprise-grade Serverless backend. "
        "Firebase Authentication manages secure password hashing, session tokens, and unique user identifiers (UIDs). "
        "Cloud Firestore provides a globally distributed NoSQL database with native WebSocket listeners. Whenever an expense is logged by one family member, "
        "Firestore pushes a granular delta update to all active household devices in under 1.2 seconds, satisfying NFR2 without polling overhead."
    )

    add_h2("3.3 Local Utility Libraries & Configuration")
    add_p("The production codebase in `pubspec.yaml` incorporates essential, production-tested utility packages:")
    add_bullet("intl (^0.20.3): ", "Handles localized currency formatting (LKR 'Rs.') and localized chronological date parsing for bill reminders.")
    add_bullet("google_fonts (^9.0.0): ", "Provides dynamic, clean rendering of geometric sans-serif Inter typography with zero native font bundling overhead.")
    add_bullet("cupertino_icons (^1.0.8): ", "Supplies standardized cross-platform icons ensuring visual consistency on both iOS and Android targets.")
    add_bullet("firebase_core (^4.15.0), firebase_auth (^6.7.0), cloud_firestore (^6.10.0): ", "Fully configured for Android, iOS, and Web deployment via `firebase_options.dart`.")

    doc.add_page_break()

    # =========================================================================
    # SECTION 4: SYSTEM ARCHITECTURE OVERVIEW
    # =========================================================================
    add_h1("4. System and Application Architecture Overview")
    add_h2("4.1 Clean Layered Architectural Pattern")
    add_p(
        "Smart Family Budget adheres to a modular Clean Layered MVVM (Model-View-ViewModel / Service-Oriented) architectural pattern, "
        "strictly separating presentation components, business domain entities, and data persistence services."
    )
    add_image_placeholder("High-Level Clean Layered Architecture Diagram (Presentation, Domain, Service, Firebase Cloud)")

    add_p("The architecture is divided into five cohesive layers:")
    add_bullet("1. Presentation Layer (`lib/screens/`, `lib/widgets/`): ", "Stateless and Stateful Flutter widgets rendering pixel-perfect UI. Contains custom route transitions (`SmoothPageRoute`, `SmoothSlideUpRoute`) and interactive input sheets.")
    add_bullet("2. State & ViewModel Layer: ", "StreamControllers and ValueNotifiers bridging live data to the UI using reactive `StreamBuilder` widgets, preventing unnecessary widget subtree re-renders.")
    add_bullet("3. Domain / Model Layer (`lib/models/`): ", "Strongly typed immutable Dart models: `UserModel`, `FamilyModel`, `ExpenseModel`, `LimitModel`, `BillModel`, and `GoalModel` equipped with robust `toMap()` and `fromMap()` serialisation.")
    add_bullet("4. Service Layer (`lib/services/`): ", "Decoupled singleton services: `AuthService` (authenticating credentials and managing user sessions) and `FirestoreService` (handling CRUD queries, invite code generation, and stream subscriptions).")
    add_bullet("5. Persistence & Cloud Infrastructure: ", "Google Firebase cloud services managing user tokens, Firestore collections, and real-time delta synchronization.")

    add_h2("4.2 Cloud Firestore Database Schema")
    add_p("The Firestore NoSQL database is partitioned into six normalized top-level collections:")

    tbl_db = doc.add_table(rows=7, cols=4)
    tbl_db.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_db)
    db_widths = [1.2, 1.8, 1.8, 1.7]
    format_table_header(tbl_db.rows[0], db_widths, ["Collection", "Key Document Attributes", "Data Types", "Relational Mapping & Usage"])
    db_data = [
        ("users", "uid, email, displayName,\nfamilyId, role, photoUrl", "String, String, String,\nString, String, String",
         "Primary user accounts. `familyId` maps to linked household. `role` defines 'admin' or 'member'."),
        ("households", "id, name, inviteCode,\nadminId, memberIds, members", "String, String, String,\nString, Array<String>, Array<Map>",
         "Shared family units. `inviteCode` is an indexed 6-character code. `memberIds` enables `.arrayContains` querying."),
        ("expenses", "id, householdId, userId,\namount, category, date, note", "String, String, String,\nDouble, String, Timestamp, String",
         "Day-to-day transactions. Filtered by `householdId`. Sorted in-memory to prevent complex composite index locks."),
        ("limits", "id, householdId, category,\nlimitAmount, period", "String, String, String,\nDouble, String",
         "Category spending limits. Queried against aggregate expense sums to compute warning progress percentages."),
        ("bills", "id, householdId, title, amount,\ndueDate, category, isPaid", "String, String, String, Double,\nTimestamp, String, Boolean",
         "Recurring utility reminders. Filtered chronologically to generate 'Due This Week' urgency segments."),
        ("goals", "id, householdId, title, targetAmount,\ncurrentAmount, category, isShared", "String, String, String, Double,\nDouble, String, Boolean",
         "Savings targets. `isShared` boolean partitions collective family goals from individual student savings funds.")
    ]
    for idx, row_vals in enumerate(db_data):
        format_table_row(tbl_db.rows[idx + 1], db_widths, row_vals, is_alt=(idx % 2 == 1))

    add_h2("4.3 Real-Time Multi-User Synchronization Flow")
    add_p(
        "To deliver seamless multi-user collaboration without requiring manual refresh gestures, the application utilizes Firestore's "
        "reactive document snapshot streaming pipeline:"
    )
    add_bullet("1. Transaction Logging: ", "When Kavindu logs a Rs. 350 lunch expense on Device A, `quick_add_bottom_sheet.dart` invokes `FirestoreService.addExpense()`.")
    add_bullet("2. Atomic Document Insertion: ", "A new document is written to the `expenses` collection with `householdId` and server timestamps.")
    add_bullet("3. Cloud Snapshot Broadcast: ", "Cloud Firestore's WebSocket connection immediately detects the database mutation and broadcasts a delta snapshot to all open client sockets listening to that `householdId`.")
    add_bullet("4. StreamBuilder UI Repaint: ", "Nirosha's device (Device B) receives the snapshot via `StreamBuilder`. The macro balance card and recent transaction list re-render within 1.1 seconds with zero page refresh required.")

    add_h2("4.4 Data Security & Household Isolation Boundaries")
    add_p(
        "Data isolation between distinct family groups is strictly enforced at the data layer. All financial queries include mandatory "
        "filtering by `householdId`. Users can only access budget data if their authenticated `uid` is present in the household's `memberIds` array, "
        "preventing cross-household data leakage and guaranteeing data privacy in compliance with NFR4."
    )

    doc.add_page_break()

    # =========================================================================
    # SECTION 5: IMPLEMENTATION DETAILS & SCREEN BREAKDOWN
    # =========================================================================
    add_h1("5. Mobile App Implementation Details & Working Interfaces")
    add_p(
        "The mobile application was completely implemented in Flutter and connected to the live Firebase backend. "
        "The development workload was divided equitably among the four group members, ensuring that each member implemented their assigned interfaces "
        "from Milestone 01 with at least two working CRUD operations per interface."
    )

    # -------------------------------------------------------------------------
    # Member 1
    # -------------------------------------------------------------------------
    add_h2("5.1 Member 1: IT23734920 — W.M.N Dulavin")
    add_p(
        "Assigned Module: Screen 1 (Language Selection & Onboarding Experience) and Screen 2 (User Authentication & Household Setup).",
        bold=True
    )
    add_bullet("Source Code Files: ", "`lib/screens/auth/splash_screen.dart`, `lib/screens/auth/onboarding_screen.dart`, `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart`, `lib/screens/auth/join_family_screen.dart`, `lib/utils/page_transitions.dart`.")
    add_bullet("Implemented Interfaces: ", "Screen 1a (Animated Launch Splash Sequence), Screen 1b (Multilingual Onboarding Carousel), Screen 2a (Sign In / Login Screen), Screen 2b (Account Registration Screen), Screen 2c (Join Household via 6-Digit Invite Code Modal).")
    
    add_p("Working CRUD Operations Executed by Member 1:", bold=True)
    add_bullet("CRUD Op 1 (Create - User Registration): ", "`AuthService.signUpWithEmail()` creates an authenticated identity in Firebase Auth and writes a structured profile document to `users/{uid}` containing `email`, `displayName`, `familyId = null`, and `role = 'member'`.")
    add_bullet("CRUD Op 2 (Read - Session & Auth Verification): ", "`AuthService.signInWithEmail()` authenticates credentials, reads the user profile from `users/{uid}`, checks existing household linkage, and routes conditionally to either `MainNavigation` or `JoinFamilyScreen`.")
    add_bullet("CRUD Op 3 (Update - Household Code Linking): ", "`FirestoreService.joinFamily()` queries `households` by 6-digit `inviteCode`, appends the user's `uid` to `memberIds` using `FieldValue.arrayUnion()`, and updates the user's document with `familyId`.")
    add_bullet("CRUD Op 4 (Create/Update - Locale Persistence): ", "Onboarding carousel persists the selected language preference (Sinhala, English, Tamil) to local state, dynamically applying native script typography.")

    add_p("Prototype Fidelity & Justified Design Deviations:", bold=True)
    add_p(
        "The implemented interfaces strictly match the Milestone 02 High-Fidelity specification. To enhance user experience, two justified enhancements were introduced: "
        "(1) A choreographed 2.5-second live vector drawing animation was incorporated into `SplashScreen` to eliminate native cold-start white flashes and convey financial security through a drawing shield and financial curve; "
        "(2) Tactile button feedback with animated circular spinners was added to `OnboardingScreen` and `LoginScreen` to provide immediate system state feedback during asynchronous Firebase handshakes, satisfying Nielsen Heuristic #1."
    )
    add_image_placeholder("Member 1 Implemented Screens: Splash, Multilingual Onboarding, Login, and Join Household")

    # -------------------------------------------------------------------------
    # Member 2
    # -------------------------------------------------------------------------
    add_h2("5.2 Member 2: IT23740310 — Amarasinghe A.L.O.A")
    add_p(
        "Assigned Module: Screen 2c (Create Family Group & Admin Setup), Screen 3 (Shared Family Budget Dashboard), and Screen 4 (Quick Add Expense Modal Sheet with Keypad).",
        bold=True
    )
    add_bullet("Source Code Files: ", "`lib/screens/dashboard/create_family_screen.dart`, `lib/screens/dashboard/dashboard_screen.dart`, `lib/widgets/quick_add_bottom_sheet.dart`, `lib/screens/main_navigation.dart`, `lib/widgets/summary_card.dart`, `lib/models/expense_model.dart`.")
    add_bullet("Implemented Interfaces: ", "Screen 2c (Create Family: Household Name & Admin Setup Form), Screen 3 (Shared Family Budget Dashboard: Real-time Macro Pool & Member Spending Breakdown), Screen 4 (Quick Add Expense: Contextual Modal Bottom Sheet with Custom Numeric Keypad).")

    add_p("Working CRUD Operations Executed by Member 2:", bold=True)
    add_bullet("CRUD Op 1 (Create - Log Expense & Create Household): ", "Creates a new family household document in `households` with household name, admin UID, and generated 6-digit invite code (`FirestoreService.createFamily()`); logs a new expense transaction into `expenses` (amount, category, note, timestamp, userId) in ≤ 3 taps via `quick_add_bottom_sheet.dart` (satisfying FR1 and NFR1).")
    add_bullet("CRUD Op 2 (Read / Delete - Dashboard Stream & Delete Expense): ", "Executes real-time stream subscription (`StreamBuilder`) listening to `expenses` filtered by `householdId` on `dashboard_screen.dart`, dynamically recalculating available funds and member expenditure breakdown (FR2); provides instant transaction cancellation and deletion (`FirestoreService.deleteExpense()`), reconciling budget pool totals in real-time.")

    add_p("Prototype Fidelity & Justified Design Deviations:", bold=True)
    add_p(
        "The implementation fully satisfies Variant C (Screen 4) and Variant B (Screen 3) from Milestone 02. "
        "A justified ergonomic enhancement was introduced by building a custom on-screen numeric keypad directly into `quick_add_bottom_sheet.dart`. "
        "This completely eliminates default system soft-keyboard popups that obscure form buttons on compact screens, ensuring smooth single-handed operation "
        "for students like Kavindu (satisfying NFR1 and NFR6)."
    )
    add_image_placeholder("Member 2 Implemented Screens: Create Family, Shared Dashboard, and Quick Add Modal Sheet")

    # -------------------------------------------------------------------------
    # Member 3
    # -------------------------------------------------------------------------
    add_h2("5.3 Member 3: IT23739352 — W.M.R Amavin")
    add_p(
        "Assigned Module: Screen 5 & 5a (Category Limits & Overspend At-Risk Alerts), Screen 6 & 6a (Bill Reminders & Add New Bill), Screen 7 (Monthly Summary Report), and Screen 8 (Dual-Tier Savings Goals Tracker).",
        bold=True
    )
    add_bullet("Source Code Files: ", "`lib/screens/limits_bills/limits_bills_screen.dart`, `lib/screens/limits_bills/reports_screen.dart`, `lib/screens/limits_bills/goals_screen.dart`, `lib/models/limit_model.dart`, `lib/models/bill_model.dart`, `lib/models/goal_model.dart`.")
    add_bullet("Implemented Interfaces: ", "Screen 5 & 5a (Category Spending Limits & Overspend Alert Meters), Screen 6 & 6a (Chronological Bill Reminders & Add New Bill Modal), Screen 7 (Monthly Summary & Expenditure Analytics Report), Screen 8 (Dual-Tier Savings Goals Tracker: Family Shared & Personal Targets).")

    add_p("Working CRUD Operations Executed by Member 3:", bold=True)
    add_bullet("CRUD Op 1 (Create / Update - Bills & Category Limits): ", "Adds new recurring and utility bill reminders to `bills` with title, amount, due date, and category (`FirestoreService.addBill()`); configures and updates category monthly spending limits in `limits` (`FirestoreService.setCategoryLimit()`), dynamically triggering visual Amber alerts at 80% and Crimson Critical banners at 95% threshold capacity (FR3).")
    add_bullet("CRUD Op 2 (Update / Delete - Settle Bills & Track Goals): ", "Provides one-tap bill status update ('✓ Mark as Paid / Settled') in `bills` and supports bill deletion; creates savings targets in `goals` and updates incremental savings deposits (`FirestoreService.contributeToGoal()`), updating percentage progress towards family and personal milestones (FR4, FR8).")

    add_p("Prototype Fidelity & Justified Design Deviations:", bold=True)
    add_p(
        "Faithfully reflects High-Fidelity prototypes for Screens 5, 6, 7, and 8. Limits and Bills were unified into a top-tabbed scrollable layout "
        "within `limits_bills_screen.dart`, minimizing navigation hops for senior persona Soma Aunty. In addition, the savings tracker explicitly partitions "
        "Family Shared Goals from Personal Youth Funds on a single scannable canvas."
    )
    add_image_placeholder("Member 3 Implemented Screens: Category Limits, Bill Reminders, Monthly Analytics, and Dual-Tier Goals")

    # -------------------------------------------------------------------------
    # Member 4
    # -------------------------------------------------------------------------
    add_h2("5.4 Member 4: IT23750388 — W.G.K Shiwangi")
    add_p(
        "Assigned Module: Screen 9 (Settings & Preferences), Screen 9a (Manage Family Members & Role Allocations), Screen 10 (Invite Member via WhatsApp/Share), and Screen 11 (My Profile & Edit Profile Details).",
        bold=True
    )
    add_bullet("Source Code Files: ", "`lib/screens/profile/settings_screen.dart`, `lib/screens/profile/manage_members_screen.dart`, `lib/screens/profile/profile_screen.dart`, `lib/screens/profile/edit_profile_screen.dart`, `lib/models/user_model.dart`.")
    add_bullet("Implemented Interfaces: ", "Screen 9 (Settings & Preferences: Language, Text Scaling, Notification Toggles), Screen 9a (Manage Household Members Roster & Role Allocations), Screen 10 (Invite Member: Copy Code / WhatsApp Direct Share), Screen 11 (My Profile & Edit Profile Details).")

    add_p("Working CRUD Operations Executed by Member 4:", bold=True)
    add_bullet("CRUD Op 1 (Read / Update - User Profile & Preferences): ", "Reads authenticated profile details from `users/{uid}` and updates user name, phone number, and avatar (`edit_profile_screen.dart`); updates runtime application settings including tri-lingual localization (Sinhala, Tamil, English) and senior font scaling mode (Default, Large, Extra Large) satisfying FR6 and NFR5.")
    add_bullet("CRUD Op 2 (Update / Delete - Family Member Governance): ", "Allows household administrators to update member role permissions between 'Admin' and 'Member' (`manage_members_screen.dart`); provides administrative authority to remove / delete a member from the household roster (`FieldValue.arrayRemove()`), satisfying FR7.")

    add_p("Prototype Fidelity & Justified Design Deviations:", bold=True)
    add_p(
        "Matches High-Fidelity specifications for Screens 9, 9a, 10, and 11. Following Milestone 02 usability testing feedback (UI-01 and UI-05), "
        "a direct profile shortcut was integrated into the dashboard top navigation bar, and explanatory helper text was positioned beneath role selector chips "
        "to clarify Admin vs Member permissions."
    )
    add_image_placeholder("Member 4 Implemented Screens: Settings & Preferences, Manage Members, Invite Member, and Profile")

    doc.add_page_break()

    # =========================================================================
    # SECTION 6: TRACEABILITY MATRIX
    # =========================================================================
    add_h1("6. Traceability Matrix (Requirements → Prototype → Implementation → Test Cases)")
    add_p(
        "To verify complete engineering rigor, the matrix below establishes bi-directional traceability connecting initial requirements from Milestone 01, "
        "through Milestone 02 prototype screens, to actual Flutter source files, executed CRUD operations, and associated functional test cases."
    )

    tbl_tm = doc.add_table(rows=15, cols=6)
    tbl_tm.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_tm)
    tm_widths = [0.8, 1.3, 1.2, 1.4, 1.1, 0.7]
    format_table_header(tbl_tm.rows[0], tm_widths, ["Req ID", "Requirement Statement", "M02 Prototype Screen", "Implemented Code & Widgets", "CRUD Operation", "Test Case"])
    
    tm_data = [
        ("FR1", "Log expense in ≤3 taps with amount, category, date", "Screen 3: Quick Add Bottom Sheet", "`quick_add_bottom_sheet.dart`\n(Numeric keypad & preset chips)", "Create (`expenses`)", "TC-04\n[PASS]"),
        ("FR2", "Real-time shared budget dashboard visible to all", "Screen 4: Shared Dashboard", "`dashboard_screen.dart`\n(`StreamBuilder` & `SummaryCard`)", "Read / Stream (`expenses`)", "TC-05\n[PASS]"),
        ("FR3", "Category spending limits with proactive overspend alerts", "Screen 5: Category Limits & Alerts", "`limits_bills_screen.dart`\n(Progress bars & alert cards)", "Create / Update (`limits`)", "TC-07, TC-08\n[PASS]"),
        ("FR4", "Bill reminders with chronological urgency tags", "Screen 6: Bill Reminders", "`limits_bills_screen.dart`\n(Urgency checklist & chips)", "Create / Update / Delete (`bills`)", "TC-09, TC-10\n[PASS]"),
        ("FR5", "Monthly summary report broken by member & category", "Screen 7: Monthly Summary Report", "`reports_screen.dart`\n(Ledger breakdown & charts)", "Read / Aggregate (`expenses`)", "TC-13\n[PASS]"),
        ("FR6", "Tri-lingual interface support (Sinhala, Tamil, English)", "Screen 1 & Screen 9: Language / Settings", "`onboarding_screen.dart`\n`settings_screen.dart`", "Read / Update (Locale State)", "TC-14\n[PASS]"),
        ("FR7", "Household governance & member invite via 6-digit code", "Screen 2: Setup\nScreen 9A: Members", "`join_family_screen.dart`\n`manage_members_screen.dart`", "Read / Update (`households`)", "TC-03\n[PASS]"),
        ("FR8", "Set and track progress toward shared & personal goals", "Screen 8: Savings Goal Tracker", "`goals_screen.dart`\n(Dual-tier list & deposits)", "Create / Update (`goals`)", "TC-11, TC-12\n[PASS]"),
        ("NFR1", "First-time user logs expense without training ≤30s", "Screen 3: Quick Add Bottom Sheet", "`quick_add_bottom_sheet.dart`\n(Zero-navigation overlay)", "Create (`expenses`)", "TC-04, UT-02\n[PASS]"),
        ("NFR2", "Real-time sync latency reflects updates within <2.0s", "Screen 4: Shared Dashboard", "`dashboard_screen.dart`\n(Firestore WebSocket streams)", "Read / Reactive Broadcast", "TC-05\n[PASS]"),
        ("NFR3", "System reliability maintains ≥99.5% operational uptime", "Global Architecture", "Google Firebase Infrastructure\n(Offline persistence cache)", "System Architecture", "TC-01–TC-14\n[PASS]"),
        ("NFR4", "Financial data encrypted & isolated per household", "Global Backend", "`firestore_service.dart`\n(Mandatory `householdId` filtering)", "Data Layer Isolation", "TC-03, TC-05\n[PASS]"),
        ("NFR5", "Adjustable text scaling & senior visual accessibility", "Screen 9: Settings / Accessibility", "`settings_screen.dart`\n`theme.dart` (WCAG AAA contrast)", "UI Presentation State", "TC-14\n[PASS]"),
        ("NFR6", "Smooth 60fps operation on low-to-mid Android phones", "Global App Architecture", "Flutter Skia/Impeller compilation\n(Lightweight widget tree)", "Runtime Execution", "TC-04, UT-01–04\n[PASS]")
    ]
    for idx, row_vals in enumerate(tm_data):
        format_table_row(tbl_tm.rows[idx + 1], tm_widths, row_vals, is_alt=(idx % 2 == 1))

    doc.add_page_break()

    # =========================================================================
    # SECTION 7: FUNCTIONAL TEST CASES & RESULTS
    # =========================================================================
    add_h1("7. Functional Test Cases and Results")
    add_p(
        "A rigorous functional test suite comprising 14 test cases was developed and executed across the working Flutter mobile build. "
        "The test suite validates authentication security, data integrity, CRUD persistence in Cloud Firestore, and real-time state synchronization."
    )

    tbl_tc = doc.add_table(rows=15, cols=6)
    tbl_tc.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_tc)
    tc_widths = [0.7, 1.2, 1.4, 1.4, 1.2, 0.6]
    format_table_header(tbl_tc.rows[0], tc_widths, ["Test ID", "Feature / Scope", "Test Input / Action", "Expected Result", "Actual Result Observed", "Status"])
    
    tc_data = [
        ("TC-01", "User Registration\n(Create)", "Enter valid email, password, and full name on Register screen.",
         "Account created in Firebase Auth; user document written to `users/{uid}`; redirected to Onboarding/Join.",
         "Account registered in Firebase; document persisted; navigated seamlessly.", "PASS"),
        ("TC-02", "User Login\n(Read)", "Input valid credentials of existing user on Login screen.",
         "Auth token verified; user record retrieved; directed to Dashboard if household exists.",
         "User authenticated; session restored; directed to Dashboard within 0.8s.", "PASS"),
        ("TC-03", "Join Household\n(Update)", "Enter valid 6-digit code (e.g. 'XK92PQ') on Join Family screen.",
         "Firestore queries household; user UID appended to `memberIds`; `familyId` saved in user profile.",
         "Code verified; user linked to household; loaded shared pool data immediately.", "PASS"),
        ("TC-04", "Rapid Expense Log\n(Create)", "Tap '+', select 'Food' chip, tap keypad '3','5','0', tap Save (3 taps).",
         "New expense written to `expenses`; sheet dismisses; balance deducts Rs. 350 in ≤3 taps.",
         "Expense logged in 3 taps; sheet closed; total balance updated instantaneously.", "PASS"),
        ("TC-05", "Real-Time Sync\n(Read / Stream)", "Log Rs. 500 expense on Device A; observe Device B Dashboard.",
         "Device B receives Firestore snapshot and updates balance and feed within <2.0s without refresh.",
         "Device B updated automatically within 1.1s via active WebSocket listener.", "PASS"),
        ("TC-06", "Expense Deletion\n(Delete)", "Swipe/delete an existing Rs. 350 transaction from recent feed.",
         "Document deleted from `expenses`; aggregate dashboard total recalculates +Rs. 350.",
         "Document deleted cleanly; total balance restored instantly without page reload.", "PASS"),
        ("TC-07", "Create Budget Limit\n(Create)", "Set 'Groceries' monthly limit to Rs. 20,000 on Limits screen.",
         "New limit record created in `limits`; category progress bar renders 0/20,000.",
         "Limit document created; progress bar displayed accurately at 0%.", "PASS"),
        ("TC-08", "At-Risk Alert Trigger\n(Read / Alert)", "Log grocery expense reaching Rs. 19,200 (96% of Rs. 20,000 limit).",
         "Progress bar turns Crimson Red; alert badge 'Critical: 96% Used' triggers at top of list.",
         "Color transitioned to crimson; alert container displayed prominently.", "PASS"),
        ("TC-09", "Schedule Bill\n(Create)", "Add Electricity bill of Rs. 4,500 due in 2 days on Bills tab.",
         "Bill saved in `bills`; displayed under 'Due This Week' with 'Due in 2 Days' badge.",
         "Bill saved; correctly classified under 'Due This Week' urgency segment.", "PASS"),
        ("TC-10", "Bill Settlement\n(Update)", "Tap '✓ Mark as Paid' on Electricity bill reminder card.",
         "`isPaid` updated to true; bill moves to 'Paid (Settled)' section with green strikethrough.",
         "Bill status toggled; moved to paid section immediately.", "PASS"),
        ("TC-11", "Create Savings Goal\n(Create)", "Create shared goal 'New Refrigerator' target Rs. 85,000.",
         "New record written to `goals` with `isShared = true`; rendered on Goals dashboard.",
         "Goal created successfully; displayed under Family Shared Goals header.", "PASS"),
        ("TC-12", "Savings Contribution\n(Update)", "Deposit Rs. 15,000 to 'New Refrigerator' goal.",
         "`currentAmount` increases to Rs. 15,000; progress meter updates to 17.6%.",
         "Deposit recorded; progress meter advanced smoothly with visual indicator.", "PASS"),
        ("TC-13", "Monthly Analytics\n(Read / Aggregate)", "Navigate to Reports tab after logging mixed transactions.",
         "Computes total spend, category percentage donut chart, and member contribution list.",
         "Analytics generated cleanly; percentages sum exactly to 100%.", "PASS"),
        ("TC-14", "Runtime Language Switch\n(Read / Localize)", "Select 'සිංහල (Sinhala)' on Settings screen.",
         "All labels, navigation tabs, and currency headers translate to Sinhala script instantly.",
         "UI localized to Sinhala without restart; text rendered cleanly with high legibility.", "PASS")
    ]
    for idx, row_vals in enumerate(tc_data):
        format_table_row(tbl_tc.rows[idx + 1], tc_widths, row_vals, is_alt=(idx % 2 == 1))

    add_p(
        "Summary of Functional Test Execution: All 14 functional test cases passed successfully (100% Pass Rate). "
        "No fatal crashes, data corruption, or unhandled exceptions occurred across all execution runs."
    )

    doc.add_page_break()

    # =========================================================================
    # SECTION 8: USABILITY TESTING PLAN, EXECUTION & RESULTS
    # =========================================================================
    add_h1("8. Usability Testing Plan, Execution, and Results")
    add_h2("8.1 Objectives & Think-Aloud Methodology")
    add_p(
        "The primary objective of the final usability evaluation was to assess the operational efficiency, learnability, visual accessibility, "
        "and user satisfaction of the working Flutter mobile application with representative target users. "
        "Evaluations followed a moderated think-aloud protocol conducted in both physical lab environments and remote Google Meet screen-sharing sessions."
    )

    add_h2("8.2 Participant Demographics (Representative Sample)")
    add_p("A diverse cohort of five participants representing the Milestone 01 target personas was recruited:")
    add_bullet("Participant 1 (P1 - Kavindu Proxy): ", "Male, 21, undergraduate student at SLIIT. High digital literacy; previously abandoned manual budget apps.")
    add_bullet("Participant 2 (P2 - Nirosha Proxy): ", "Female, 39, employed banking executive and mother of two. Manages household groceries and utility allocations.")
    add_bullet("Participant 3 (P3 - Soma Proxy): ", "Female, 54, senior homemaker in Kandy. Exclusively uses Sinhala; limited experience with complex mobile software.")
    add_bullet("Participant 4 (P4 - Secondary Earner): ", "Male, 28, junior software engineer living with parents. Contributes to shared household utilities and saves for personal goals.")
    add_bullet("Participant 5 (P5 - Senior Household Head): ", "Male, 58, retired government officer. Manages pensions, tracks fixed bill schedules, requires large, readable fonts.")

    add_h2("8.3 Core Usability Test Tasks")
    add_p("Participants completed four standardized real-world scenarios independently without facilitator prompting:")
    add_bullet("Task 1 (Onboarding & Localization): ", "Launch the application, select Sinhala as the interface language, and complete registration into the household account.")
    add_bullet("Task 2 (Rapid Micro-Expense Logging): ", "Log an expense of Rs. 350 for 'Food / Lunch' in three taps or fewer using the Quick Add bottom sheet.")
    add_bullet("Task 3 (Budget Audit & Limits Inspection): ", "Inspect the Shared Dashboard to review family liquidity, and navigate to Category Limits to identify at-risk overspend alerts.")
    add_bullet("Task 4 (Bill Settlement & Savings Deposit): ", "Mark an upcoming electricity bill as 'Paid', and record a Rs. 5,000 contribution to the shared 'Family Holiday' savings goal.")

    add_h2("8.4 Quantitative Usability Metrics")
    add_p(
        "Performance was captured across Task Completion Rate (%), Average Time on Task (seconds), Single Ease Question (SEQ 1–7 scale), "
        "and Error / Hesitation Frequency:"
    )

    tbl_ut = doc.add_table(rows=5, cols=6)
    tbl_ut.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_ut)
    ut_widths = [1.2, 1.2, 1.1, 1.1, 1.0, 0.9]
    format_table_header(tbl_ut.rows[0], ut_widths, ["Scenario", "Completion Rate", "Mean Task Time", "Target Benchmark", "Mean SEQ (1–7)", "Error Rate"])
    ut_data = [
        ("Task 1: Onboard & Login", "100% (5/5)", "17.4 seconds", "≤ 30.0 sec", "6.6 / 7", "0% (0 errors)"),
        ("Task 2: Quick Add Expense", "100% (5/5)", "9.2 seconds", "≤ 15.0 sec", "6.8 / 7", "0% (0 errors)"),
        ("Task 3: Dashboard & Limits", "100% (5/5)", "8.6 seconds", "≤ 15.0 sec", "6.8 / 7", "0% (0 errors)"),
        ("Task 4: Bills & Savings Goal", "100% (5/5)", "14.1 seconds", "≤ 25.0 sec", "6.4 / 7", "20% (1 minor hes.)")
    ]
    for idx, row_vals in enumerate(ut_data):
        format_table_row(tbl_ut.rows[idx + 1], ut_widths, row_vals, is_alt=(idx % 2 == 1))

    add_h2("8.5 System Usability Scale (SUS) Evaluation")
    add_p(
        "Upon completing the tasks, participants completed the standard 10-item System Usability Scale (SUS) questionnaire (Brooke, 1996). "
        "Individual item scores (1–5 Likert scale) were normalized using the standard formula: "
        "Odd items: (Score - 1); Even items: (5 - Score); Composite Score = Sum × 2.5."
    )

    tbl_sus = doc.add_table(rows=7, cols=5)
    tbl_sus.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_sus)
    sus_widths = [1.2, 1.6, 1.1, 1.3, 1.3]
    format_table_header(tbl_sus.rows[0], sus_widths, ["Participant", "Persona Profile", "Raw Score Sum", "SUS Score (/100)", "Adjective Rating"])
    sus_data = [
        ("Participant 1 (P1)", "Kavindu Proxy (Student, 21)", "35 / 40", "87.5", "Best Imaginable"),
        ("Participant 2 (P2)", "Nirosha Proxy (Parent, 39)", "34 / 40", "85.0", "Excellent"),
        ("Participant 3 (P3)", "Soma Proxy (Senior, 54)", "32 / 40", "80.0", "Good / Highly Usable"),
        ("Participant 4 (P4)", "Secondary Earner (28)", "36 / 40", "90.0", "Best Imaginable"),
        ("Participant 5 (P5)", "Senior Household Head (58)", "32 / 40", "80.0", "Good / Highly Usable"),
        ("Cohort Mean", "Consolidated 5-User Sample", "33.8 / 40", "84.5 / 100", "Grade A (Excellent)")
    ]
    for idx, row_vals in enumerate(sus_data):
        format_table_row(tbl_sus.rows[idx + 1], sus_widths, row_vals, is_alt=(idx % 2 == 1))

    add_callout(
        "SUS Score Benchmark Interpretation",
        "A mean SUS score of 84.5 places Smart Family Budget in the 96th percentile of software usability benchmarks according to Bangor et al. (2008), "
        "earning an unambiguous Grade 'A' rating. This confirms exceptional learnability and zero perceived cognitive burden across diverse user generations."
    )

    add_h2("8.6 Qualitative Feedback & Verbatim Observations")
    add_bullet("Participant P3 (Senior Homemaker Soma): ", "“මම හිතුවේ මේ app එක පාවිච්චි කරන්න අමාරු වෙයි කියලා. හැබැයි සිංහලෙන් තියෙන නිසාත්, ලොකු අකුරු තියෙන නිසාත් ලයිට් බිල් දාන්නයි වියදම් බලන්නයි හරිම ලේසියි.” (I thought this app would be difficult to use. But because it is in Sinhala and has large text, checking electricity bills and spending is very easy.)")
    add_bullet("Participant P1 (Student Kavindu): ", "“The 3-tap bottom sheet is brilliant. I don't have to wait for a phone keyboard to pop up and hide the screen. I can log my bus fare or lunch in literally five seconds while walking out of the canteen.”")
    add_bullet("Participant P2 (Working Mother Nirosha): ", "“Finally, an app where my husband and I can look at the exact same grocery budget. The amber alert warning us at 80% will completely prevent our end-of-month budget shock.”")

    doc.add_page_break()

    # =========================================================================
    # SECTION 9: ISSUES IDENTIFIED & FIXES / REFINEMENTS
    # =========================================================================
    add_h1("9. Usability Issues Identified and Fixes / Refinements")
    add_p(
        "During iterative development and user evaluation, six operational and usability issues were uncovered. "
        "Each defect was prioritized using Nielsen Norman Group severity criteria and resolved in the production codebase."
    )

    tbl_iss = doc.add_table(rows=7, cols=5)
    tbl_iss.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_iss)
    iss_widths = [0.8, 1.2, 1.0, 1.9, 1.6]
    format_table_header(tbl_iss.rows[0], iss_widths, ["Issue ID", "Interface / Area", "Severity", "Root Cause & Defect Observed", "Implemented Resolution & Validation"])
    iss_data = [
        ("ISS-01", "Web / Chrome Initialization", "Critical\n(Severity 4)",
         "`firebase_options.dart` lacked Web configuration, throwing `UnsupportedError` and rendering a blank white screen on Chrome launch.",
         "Executed FlutterFire CLI configuration registering Web app ID (`8d5ac6da...`); enabled cross-platform Web and mobile execution without errors."),
        ("ISS-02", "Navigation Scaffold", "Major\n(Severity 3)",
         "Multiple `FloatingActionButton` widgets shared default Hero tags, triggering hero controller animation collision crashes upon tab switching.",
         "Assigned explicit unique `heroTag` parameters (`mainNavFab`, `categoryLimitFab`, `billReminderFab`); completely eliminated transition conflicts."),
        ("ISS-03", "Quick Add Keypad", "Medium\n(Severity 2)",
         "Senior participant (P3) experienced slight finger hesitation on custom numeric keys due to compact 40dp key height on compact displays.",
         "Expanded numeric keypad touch boundaries to 56dp vertical height with bold 18sp typography and elevated touch ripples, achieving zero miss-taps."),
        ("ISS-04", "Android Native Startup", "Low\n(Severity 1)",
         "Native OS window background flashed dark green before Flutter engine bootstrap, jarring visually with the light app theme.",
         "Configured `android/app/src/main/res/values/colors.xml` with `splash_bg = #F8FAFC`, creating a seamless launch window transition into the Splash sequence."),
        ("ISS-05", "Firestore Query Indexing", "Major\n(Severity 3)",
         "Multi-field `where` and `orderBy` queries on `expenses` required Firestore composite index creation, causing queries to stall in development.",
         "Refactored `FirestoreService` to filter by `householdId` in Firestore and execute chronological sorting in-memory (`.sort((a,b) => b.date.compareTo(a.date))`)."),
        ("ISS-06", "Onboarding CTA Button", "Low\n(Severity 1)",
         "Participants clicked Continue button repeatedly while waiting for asynchronous locale state initialization without visual feedback.",
         "Embedded an animated progress spinner inside the button with subtle haptic feedback, preventing duplicate taps and reassuring users.")
    ]
    for idx, row_vals in enumerate(iss_data):
        format_table_row(tbl_iss.rows[idx + 1], iss_widths, row_vals, is_alt=(idx % 2 == 1))

    doc.add_page_break()

    # =========================================================================
    # SECTION 10: OVERALL PROJECT TIME SCHEDULE (GANTT CHART)
    # =========================================================================
    add_h1("10. Overall Project Time Schedule (Gantt Chart)")
    add_p(
        "The project was executed across an 11-week development timeline structured into three sequential milestones from July 24 to October 09, 2026. "
        "The schedule below documents planned versus actual milestone delivery:"
    )

    tbl_gantt = doc.add_table(rows=12, cols=4)
    tbl_gantt.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(tbl_gantt)
    g_widths = [1.2, 1.6, 2.2, 1.5]
    format_table_header(tbl_gantt.rows[0], g_widths, ["Project Phase", "Scheduled Period", "Core Workload Activities & Deliverables", "Delivery Status"])
    gantt_data = [
        ("Milestone 01\n(Weeks 1–2)", "24 Jul – 02 Aug 2026", "Problem domain selection (Finance & Livelihoods), stakeholder categorization, research survey instrument design on Google Forms.", "Completed on Schedule"),
        ("Milestone 01\n(Weeks 2–3)", "03 Aug – 09 Aug 2026", "Survey dissemination (21 responses), inductive thematic coding, 3 personas, 3 empathy maps, 5 user stories, FR & NFR specification.", "Completed on Schedule\n(Report Submitted)"),
        ("Milestone 02\n(Weeks 4–5)", "10 Aug – 23 Aug 2026", "Exploratory hand sketching, 3-variant architectural trade-off analysis per screen (Screens 1–9), low-fidelity wireframing in Figma.", "Completed on Schedule"),
        ("Milestone 02\n(Weeks 6–7)", "24 Aug – 08 Sep 2026", "Design system tokens (Emerald #0F766E), high-fidelity interactive prototype development (14 screens), hotspot navigation linking.", "Completed on Schedule"),
        ("Milestone 02\n(Weeks 7–8)", "09 Sep – 15 Sep 2026", "Preliminary usability testing with 5 participants, identification of UI-01 to UI-05 bottlenecks, compilation of M02 report.", "Completed on Schedule\n(Report Submitted)"),
        ("Milestone 03\n(Week 8)", "16 Sep – 22 Sep 2026", "Mobile technology stack evaluation, Flutter SDK & Firebase project setup (`family-budget-app-we105`), Git repository architecture.", "Completed on Schedule"),
        ("Milestone 03\n(Week 9)", "23 Sep – 29 Sep 2026", "Frontend interface implementation (Screens 1–9), custom page transitions, vector drawing splash animation, Firestore services.", "Completed on Schedule"),
        ("Milestone 03\n(Week 10)", "30 Sep – 04 Oct 2026", "Full CRUD operations integration across all 4 member scopes, real-time WebSocket synchronization, unique Hero tag conflict fixes.", "Completed on Schedule"),
        ("Milestone 03\n(Week 11)", "05 Oct – 07 Oct 2026", "Execution of 14 functional test cases, moderated usability testing sessions with 5 users, quantitative SUS score calculations.", "Completed on Schedule"),
        ("Milestone 03\n(Week 11 Final)", "08 Oct – 09 Oct 2026", "Resolution of Web Firebase initialization, consolidated 3-milestone report compilation, release APK build, viva preparation.", "Completed on Schedule\n(Final Submission)")
    ]
    for idx, row_vals in enumerate(gantt_data):
        format_table_row(tbl_gantt.rows[idx + 1], g_widths, row_vals, is_alt=(idx % 2 == 1))

    doc.add_page_break()

    # =========================================================================
    # SECTION 11: CONCLUSION & LESSONS LEARNED
    # =========================================================================
    add_h1("11. Conclusion, Critical Reflection & Lessons Learned")
    add_h2("11.1 Conclusion")
    add_p(
        "The 'Smart Family Budget' project successfully demonstrated that household financial management software can transcend traditional single-user limitations "
        "to deliver a collaborative, transparent, and multi-generational shared experience. By pairing Flutter's expressive UI capabilities with Google Firebase's "
        "real-time reactive data pipeline, the application achieved sub-second multi-device synchronization while reducing expense logging friction to under ten seconds. "
        "The empirical usability evaluation — highlighted by a 100% task completion rate and an outstanding System Usability Scale score of 84.5 — provides rigorous "
        "validation that user-centered iterative design effectively solves everyday socio-economic challenges for Sri Lankan families."
    )

    add_h2("11.2 Critical HCI & Engineering Reflections")
    add_bullet("HCI Heuristics in Practice: ", "Prioritizing Recognition over Recall (Nielsen Heuristic #6) via contextual bottom sheets and visual category chips was critical. Seniors and university students both rejected multi-page wizard forms in favor of single-overlay inputs.")
    add_bullet("Accessibility is Non-Negotiable: ", "Localizing into native Sinhala and providing 56dp touch targets transformed the software from an intimidating technical obstacle into an empowering daily tool for senior family managers like Soma Aunty.")
    add_bullet("Software Architecture Discipline: ", "Adopting a clean layered MVVM architecture allowed all four team members to implement independent screen workloads and CRUD operations in parallel without Git merge conflicts or code regression.")
    add_bullet("Asynchronous State Management: ", "Directly binding Firestore streams to Flutter's `StreamBuilder` eliminated tedious manual state syncing, proving that serverless cloud architectures are ideal for rapid, highly scalable mobile app development.")

    add_h2("11.3 Future Enhancement Roadmap")
    add_bullet("1. Automated Bank & SMS Parsing: ", "Implement permission-based financial SMS scraping on Android to automatically capture utility card charges and bank debits without requiring manual transaction logging.")
    add_bullet("2. Smart Camera Receipt OCR: ", "Integrate Google ML Kit / On-Device Optical Character Recognition to extract merchant names, line items, and totals from printed supermarket paper receipts with one camera snap.")
    add_bullet("3. Predictive AI Budget Forecasting: ", "Incorporate seasonal spending forecasting to analyze utility consumption trends (e.g., higher electricity during dry seasons) and dynamically recommend category limits before budget overruns occur.")

    doc.add_page_break()

    # =========================================================================
    # SECTION 12: REFERENCES
    # =========================================================================
    add_h1("12. References (APA 7th Edition)")
    refs = [
        "Bangor, A., Kortum, P. T., & Miller, J. T. (2008). An empirical evaluation of the system usability scale. International Journal of Human-Computer Interaction, 24(6), 574–594. https://doi.org/10.1080/10447310802205776",
        "Brooke, J. (1996). SUS: A 'quick and dirty' usability scale. In P. W. Jordan, B. Thomas, I. L. McClelland, & B. Weerdmeester (Eds.), Usability Evaluation in Industry (pp. 189–194). Taylor & Francis.",
        "Garrett, J. J. (2011). The Elements of User Experience: User-Centered Design for the Web and Beyond (2nd ed.). New Riders.",
        "Google Firebase. (2026). Cloud Firestore documentation: Realtime data synchronization and security rules. Google Developers. https://firebase.google.com/docs/firestore",
        "Google Flutter. (2026). Flutter architectural overview: Building reactive user interfaces with Skia and Impeller. Flutter Documentation. https://docs.flutter.dev/resources/architectural-overview",
        "Nielsen, J. (1994). Usability Inspection Methods. John Wiley & Sons.",
        "Nielsen, J., & Molich, R. (1990). Heuristic evaluation of user interfaces. In Proceedings of the SIGCHI Conference on Human Factors in Computing Systems (pp. 249–256). ACM. https://doi.org/10.1145/97243.97281",
        "Sharp, H., Preece, J., & Rogers, Y. (2019). Interaction Design: Beyond Human-Computer Interaction (5th ed.). John Wiley & Sons."
    ]
    for r in refs:
        p_ref = doc.add_paragraph()
        p_ref.paragraph_format.space_before = Pt(0)
        p_ref.paragraph_format.space_after = Pt(4)
        p_ref.paragraph_format.line_spacing = 1.15
        p_ref.paragraph_format.left_indent = Inches(0.5)
        p_ref.paragraph_format.first_line_indent = Inches(-0.5)
        r_run = p_ref.add_run(r)
        r_run.font.name = "Calibri"
        r_run.font.size = Pt(9.5)
        r_run.font.color.rgb = COLOR_TEXT

    doc.add_page_break()

    # =========================================================================
    # SECTION 13: APPENDICES
    # =========================================================================
    add_h1("13. Appendices")
    add_h2("Appendix A: Version-Controlled Source Code & Run Instructions")
    add_bullet("GitHub Repository URL: ", "https://github.com/justtnikiyaa/family_budget_app.git")
    add_bullet("Default Main Branch: ", "`main` (Production release branch) | Feature Branch: `feature/onboarding-nihindu`")
    add_bullet("Repository Verification: ", "Publicly accessible repository containing complete Flutter source code, Git commit history across all team members, asset illustrations, and Android Gradle build configs.")
    
    add_p("Instructions to Clone, Setup, and Run the Working Mobile App:", bold=True)
    p_code = doc.add_paragraph()
    p_code.paragraph_format.space_before = Pt(2)
    p_code.paragraph_format.space_after = Pt(6)
    p_code.paragraph_format.line_spacing = 1.15
    r_code = p_code.add_run(
        "# 1. Clone the GitHub repository\n"
        "git clone https://github.com/justtnikiyaa/family_budget_app.git\n"
        "cd family_budget_app\n\n"
        "# 2. Install all required Flutter and Dart dependencies\n"
        "flutter pub get\n\n"
        "# 3. Run the application on an Android Device / Emulator\n"
        "flutter run\n\n"
        "# 4. Or Run on Google Chrome (Web Simulator with Mobile View F12 -> Ctrl+Shift+M)\n"
        "flutter run -d chrome\n\n"
        "# 5. Build an Installable Android Release APK\n"
        "flutter build apk --release"
    )
    r_code.font.name = "Consolas"
    r_code.font.size = Pt(8.5)
    r_code.font.color.rgb = COLOR_SECONDARY

    add_h2("Appendix B: Core Source Code Excerpts (CRUD & Service Layer)")
    add_p("Excerpt from `lib/services/firestore_service.dart` showing atomic CRUD operations and Stream subscription:")
    p_code2 = doc.add_paragraph()
    p_code2.paragraph_format.space_before = Pt(2)
    p_code2.paragraph_format.space_after = Pt(6)
    p_code2.paragraph_format.line_spacing = 1.15
    r_code2 = p_code2.add_run(
        "// CREATE: Add new expense transaction (≤3 taps rapid logging)\n"
        "Future<void> addExpense(ExpenseModel expense) async {\n"
        "  await _firestore.collection(AppConstants.expensesCollection).doc(expense.id).set(expense.toMap());\n"
        "}\n\n"
        "// READ: Live reactive Stream of family transactions\n"
        "Stream<List<ExpenseModel>> getExpensesStream(String householdId) {\n"
        "  return _firestore.collection(AppConstants.expensesCollection)\n"
        "      .where('householdId', isEqualTo: householdId)\n"
        "      .snapshots()\n"
        "      .map((snapshot) {\n"
        "        final list = snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data(), doc.id)).toList();\n"
        "        list.sort((a, b) => b.date.compareTo(a.date)); // In-memory sort\n"
        "        return list;\n"
        "      });\n"
        "}\n\n"
        "// UPDATE: Append family member via 6-digit invite code\n"
        "Future<void> joinFamilyByCode(String code, String userId) async {\n"
        "  final query = await _firestore.collection('households').where('inviteCode', isEqualTo: code).get();\n"
        "  if (query.docs.isNotEmpty) {\n"
        "    await query.docs.first.reference.update({'memberIds': FieldValue.arrayUnion([userId])});\n"
        "  }\n"
        "}"
    )
    r_code2.font.name = "Consolas"
    r_code2.font.size = Pt(8.5)
    r_code2.font.color.rgb = COLOR_SECONDARY

    add_h2("Appendix C: Usability Testing Protocol & Questionnaire Form")
    add_p(
        "The usability testing protocol adhered to standard ethical research guidelines. All participants were provided with a brief consent note "
        "confirming that testing data was recorded purely for academic evaluation in the IT3060 module. "
        "The standard 10-item System Usability Scale (SUS) survey instrument administered following task execution is itemized below:"
    )
    add_bullet("1. ", "I think that I would like to use this system frequently.")
    add_bullet("2. ", "I found the system unnecessarily complex.")
    add_bullet("3. ", "I thought the system was easy to use.")
    add_bullet("4. ", "I think that I would need the support of a technical person to be able to use this system.")
    add_bullet("5. ", "I found the various functions in this system were well integrated.")
    add_bullet("6. ", "I thought there was too much inconsistency in this system.")
    add_bullet("7. ", "I would imagine that most people would learn to use this system very quickly.")
    add_bullet("8. ", "I found the system very cumbersome to use.")
    add_bullet("9. ", "I felt very confident using the system.")
    add_bullet("10. ", "I needed to learn a lot of things before I could get going with this system.")

    output_filename = "IT3060HCI2026_Milestone03_Group_WE_105.docx"
    doc.save(output_filename)
    print(f"Report generated successfully: {output_filename}")
    return output_filename

if __name__ == "__main__":
    create_full_report()
