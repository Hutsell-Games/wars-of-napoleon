"""Tests of play.py, dosshot.py and make_scripts.py, the parts that need no build:
    python -I -m unittest discover -s tests -p "test_*.py"
"""
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import dosshot  # noqa: E402
import make_scripts  # noqa: E402
import play  # noqa: E402

STATE = b"screen-state 1\npages 1 display 0 write 0 read 0\np 00*640\nend\n"


class EntriesTest(unittest.TestCase):
    def test_states_digests_and_stopped(self):
        data = b"digest 0123456789ABCDEF\n" + STATE + b"stopped k line 3: no prompt in time\n"
        self.assertEqual(play.entries(data),
                         [b"digest 0123456789ABCDEF", STATE, b"stopped k line 3: no prompt in time"])

    def test_a_state_cut_short_is_kept(self):
        self.assertEqual(play.entries(b"screen-state 1\np 00\n"), [b"screen-state 1\np 00\n"])

    def test_digest_of_a_state(self):
        self.assertEqual(play.fnv1a64(b""), 0xCBF29CE484222325)
        self.assertEqual(play.fnv1a64(b"a"), 0xAF63DC4C8601EC8C)
        self.assertEqual(play.as_digest(STATE), b"digest %016X" % play.fnv1a64(STATE))
        self.assertEqual(play.as_digest(b"digest 1"), b"digest 1")

    def test_first_difference(self):
        self.assertIsNone(play.first_difference([b"a", b"b"], [b"a", b"b"]))
        self.assertEqual(play.first_difference([b"a", b"b"], [b"a", b"c"]), 1)
        self.assertEqual(play.first_difference([b"a"], [b"a", b"b"]), 1)


class ScriptTest(unittest.TestCase):
    def test_shots_follow_their_state_steps(self):
        text = "# shot 01-a\nstate\nkey space\nstate  # no shot\n# shot 02-b: why\nstate\n"
        self.assertEqual(play.shots_of(text), ["01-a", None, "02-b"])

    def test_a_game_reads_its_setup_lines(self):
        with tempfile.TemporaryDirectory() as d:
            keys = Path(d) / "g.keys"
            keys.write_text("#! seed 7\n#! timeout 60\n#! battle tests/battles/b1-innsbruck-retreat.keys\n"
                            "play until 2:M\n# shot x\nstate\n")
            s = play.game_script(keys)
        self.assertEqual((s.seed, s.timeout, s.kind, s.shots), ("7", 60, "game", ["x"]))
        self.assertEqual([p.name for p in s.battles], ["b1-innsbruck-retreat.keys"])
        self.assertIsNone(s.outcome)  # a battle starts the tactical game

    def test_a_game_without_battle_starts_none(self):
        with tempfile.TemporaryDirectory() as d:
            keys = Path(d) / "g.keys"
            keys.write_text("play until 2:W\n")
            self.assertEqual(play.game_script(keys).outcome, play.NO_OUTCOME)

    def test_a_bad_setup_line_is_an_error(self):
        with tempfile.TemporaryDirectory() as d:
            keys = Path(d) / "g.keys"
            keys.write_text("#! seeds 7\n")
            with self.assertRaises(play.SetupError):
                play.game_script(keys)

    def test_every_script_is_found_once(self):
        names = [s.name for s in play.all_scripts()]
        self.assertEqual(len(names), len(set(names)))
        self.assertIn("09-1805-tactical-battle", names)
        battled = next(s for s in play.all_scripts() if s.name == "09-1805-tactical-battle")
        self.assertIsNone(battled.outcome)
        self.assertEqual(battled.reference.name, "09-1805-tactical-battle.screen")

    def test_session_9_alone_gets_its_recorded_outcome(self):
        s = next(s for s in play.all_scripts() if s.name == "09-1805-tactical")
        self.assertTrue(s.outcome.endswith("OUTCOME.&&&"))
        self.assertEqual(s.stop_after, len(s.shots))


class OutcomeTest(unittest.TestCase):
    def test_fifteen_digits_against_sixteen(self):
        self.assertTrue(play.same_outcome("1,0,.5799999870359898", "1,0,.57999998703599"))
        self.assertTrue(play.same_outcome("3,.2399999946355820,3.999999910593033D-02",
                                          "3,.239999994635582,3.99999991059303D-02"))
        self.assertFalse(play.same_outcome("2,0,.58", "1,0,.58"))
        self.assertFalse(play.same_outcome("1,0", "1,0,0"))


class KnownTest(unittest.TestCase):
    def test_the_list_reads(self):
        known = dosshot.read_known()
        self.assertTrue(known)
        self.assertTrue(all(k.why for k in known))

    def test_a_bad_line_stops(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "k.txt"
            path.write_text("01 * box 1 2 3 -- three numbers\n")
            with self.assertRaises(SystemExit):
                dosshot.read_known(path)

    def test_patterns_and_from_a_shot_on(self):
        k = dosshot.Known("[01]*", "05-b+", "any", [], "", 1)
        shots = ["04-a", "05-b", "06-c"]
        self.assertFalse(k.applies("01-x", "04-a", shots))
        self.assertTrue(k.applies("01-x", "05-b", shots))
        self.assertTrue(k.applies("09-y", "06-c", shots))
        self.assertFalse(k.applies("b1-z", "06-c", shots))


class MaskTest(unittest.TestCase):
    def test_the_offsets_measured(self):
        self.assertEqual(len(dosshot.SHIP_OFFSETS), 12)
        self.assertEqual(len(dosshot.RAID_OFFSETS), 128)
        self.assertIn((-18, -2), dosshot.SHIP_OFFSETS)
        self.assertEqual(dosshot.marker_pixels({(10, 10)}), {(7, 7), (13, 7), (7, 13), (13, 13)})

    def test_ships_stand_where_the_map_draws_them(self):
        centers = dosshot.ship_centers()
        self.assertIn((140, 25), centers)  # London, port code 96
        self.assertIn((21, 200), centers)  # Bordeaux, 97
        self.assertIn((140, 410), centers)  # at sea

    def test_the_masks_follow_the_map_scrolled_up(self):
        masks = dosshot.map_masks()
        self.assertIn((97, 22), masks["markers"])  # London at (100, 25)
        self.assertIn((97, 6), masks["markers"])  # and 16 higher

    def test_leave_out_by_box_and_by_color(self):
        page = dosshot.Page(text=False, width=4, height=1, palette=[])
        mine, theirs = [b"\x00\xaa\x00" * 4], [b"\x00\x8a\x00" * 4]
        cells = {(0, 0): [(0, 0), (1, 0), (2, 0), (3, 0)]}
        dosshot.leave_out(dosshot.Known("*", "*", "box", ["0", "0", "1", "0"], "", 1), cells, mine, theirs, page, {})
        self.assertEqual(cells, {(0, 0): [(2, 0), (3, 0)]})
        dosshot.leave_out(dosshot.Known("*", "*", "color", ["00AA00", "008A00"], "", 2), cells, mine, theirs,
                          page, {})
        self.assertEqual(cells, {})


class TextScreenTest(unittest.TestCase):
    GLYPHS = {c: bytes([0x81] * 16) for c in range(256)}  # a left and a right stroke

    def page(self, char, attr, cursor=None):
        p = dosshot.Page(text=True, width=1, height=1,
                         palette=[0xFF000000 + i for i in range(16)], cursor=cursor)
        p.rows, p.attrs = [[char]], [[attr]]
        return p

    def test_the_ninth_column(self):
        self.assertFalse(dosshot.glyph_pixel(bytes([1] * 16), 0x41, 8, 0))
        self.assertTrue(dosshot.glyph_pixel(bytes([1] * 16), 0xC4, 8, 0))  # line drawing repeats column 8

    def test_a_cell_drawn_and_compared(self):
        p = self.page(0x41, 0x1F)
        mine = dosshot.draw_text(p, self.GLYPHS, 9, 16)
        self.assertEqual(len(mine), 16)
        self.assertEqual(len(mine[0]), 27)
        self.assertEqual(dosshot.text_cells(p, mine, mine, self.GLYPHS), {})

    def test_a_blinking_cell_may_show_its_background(self):
        p = self.page(0x41, 0x9F)
        mine = dosshot.draw_text(p, self.GLYPHS, 9, 16)
        off = dosshot.draw_text(p, self.GLYPHS, 9, 16, blink_off=True)
        self.assertNotEqual(mine, off)
        self.assertEqual(dosshot.text_cells(p, mine, off, self.GLYPHS), {})

    def test_a_text_state_reads(self):
        state = ("screen-state 1\npages 8 display 0 write 0 read 0\n"
                 "page 0 mode 0 text 2x1 bits 16 font 16 cursor 2,1 on color 15 background 0\n"
                 "palette FF000000*256\n"
                 't "A\\xB2"\na 07 1F\nend\n')
        p = dosshot.read_page(state)
        self.assertEqual((p.text, p.rows, p.attrs, p.cursor), (True, [[65, 0xB2]], [[7, 0x1F]], (2, 1)))


class MakeScriptsTest(unittest.TestCase):
    def test_the_year_and_the_side(self):
        lines = make_scripts.header("1807", "french", "")
        self.assertEqual(lines.count("key down"), 2)
        self.assertIn("text a", lines)
        self.assertNotIn("text a", make_scripts.header("1796", "allies", ""))
        self.assertIn(f"#! seed {make_scripts.seed('end-1807-french')}", lines)

    def test_the_ending(self):
        self.assertIn("play until 4", make_scripts.ending(True))
        self.assertNotIn("play until 4", make_scripts.ending(False))
        self.assertEqual(make_scripts.ending(False)[-1], "repeat space")
        self.assertEqual(make_scripts.turns(3)[2], "repeat 3")


class CoverageTest(unittest.TestCase):
    def test_rebase_keeps_the_games_files(self):
        text = ("coverage 1\nfile\t1\tx\t../WON2.BM\nfile\t2\tx\trules_test.bas\n"
                "1\t10\t1\t3\n2\t5\t1\t1\n")
        out = play.rebase_records(text)
        self.assertIn("file\t1\tx\tWON2.BM", out)
        self.assertIn("1\t10\t1\t3", out)
        self.assertNotIn("2\t5\t1\t1", out)

    def test_a_program_keeps_its_own_files(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "c.txt"
            path.write_text("coverage 1\nfile\t1\tx\tWON2.BM\nfile\t2\tx\tNAP1.BM\nfile\t3\tx\tQB64.BM\n"
                            "1\t10\t1\t3\n2\t5\t1\t1\n3\t7\t1\t2\n")
            out = play.program_records(path, "won", Path(d) / "won.txt").read_text()
            self.assertIn("1\t10\t1\t3", out)
            self.assertIn("3\t7\t1\t2", out)
            self.assertNotIn("NAP1.BM", out)
            self.assertNotIn("2\t5\t1\t1", out)
            path.write_text("coverage 1\nfile\t1\tx\tWON2.BM\n1\t10\t1\t3\n")
            self.assertIsNone(play.program_records(path, "napoleon", Path(d) / "nap.txt"))


if __name__ == "__main__":
    unittest.main()
