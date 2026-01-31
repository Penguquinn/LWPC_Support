FOPT=-O3 -mavx -march=native -ffast-math
FDBG=-Wall -fcheck=all -g
FPROF=$(FDBG) -O0 -fprofile-arcs -ftest-coverage -pg
FFLAGS=$(FOPT) -fallow-argument-mismatch -fno-automatic -finit-local-zero -I../include 
FC=gfortran

object_files=clineq.o \
             day_number.o \
             decode_a_noise.o \
             decode_control_data.o \
             decode_date.o \
             decode_file_name.o \
             decode_ionosphere.o \
             decode_list_flt.o \
             decode_list_int.o \
             decode_list_str.o \
             decode_map_area.o \
             decode_op_area.o \
             decode_plotter.o \
             decode_rx_data.o \
             decode_time.o \
             decode_tx_data.o \
             erfc.o \
             flush_unit.o \
             gcdbr.o \
             gcdbr2.o \
             geo_subsolar.o \
             get_command_line.o \
             get_date.o \
             get_delimiter.o \
             get_map.o \
             get_opa.o \
             get_random.o \
             get_time.o \
             get_xmtr.o \
             ground.o \
             hrs_to_hhmm.o \
             land_sea.o \
             leap_year.o \
             lwpc_dat_loc.o \
             lwpc_error.o \
             lwp_driver.o \
             lwp_eof_mds.o \
             lwp_get_brng.o \
             lwp_input.o \
             lwp_path.o \
             lwp_preseg.o \
             lwp_save_mc.o \
             lwp_set_brng.o \
             lwp_to_edge.o \
             lw_fast_mc.o \
             lw_full_mc.o \
             lw_htgain.o \
             lw_read_mds.o \
             lw_step.o \
             lw_sum_modes.o \
             lw_vs_d.o \
             mc_p_integ.o \
             mf_bndrys.o \
             mf_brncpt.o \
             mf_cheklg.o \
             mf_driver.o \
             mf_emtrx.o \
             mf_fctval.o \
             mf_fdfdt.o \
             mf_final.o \
             mf_finllg.o \
             mf_fsintg.o \
             mf_fzeros.o \
             mf_get_mc.o \
             mf_initev.o \
             mf_initlg.o \
             mf_initoe.o \
             mf_initr.o \
             mf_integ.o \
             mf_introe.o \
             mf_lagrng.o \
             mf_lgtori.o \
             mf_mdhnkl.o \
             mf_quartc.o \
             mf_rbars.o \
             mf_rderiv.o \
             mf_rmtrx.o \
             mf_roemtx.o \
             mf_smtrx.o \
             mf_subdiv.o \
             mf_tmtrx.o \
             mf_todlgs.o \
             mf_wgsort.o \
             mf_which.o \
             mf_wvgd.o \
             mf_xderiv.o \
             mf_xfer.o \
             month_name.o \
             month_number.o \
             newmag.o \
             noise_itsn.o \
             noise_ntia.o \
             opa_interpolate.o \
             opa_noise_grid.o \
             opa_read_lwf.o \
             opa_set_up_grid.o \
             opa_signal_grid.o \
             open_dat.o \
             prfl_chi_exp.o \
             prfl_chi_tbl.o \
             prfl_ennu.o \
             prfl_exp.o \
             prfl_gtbl.o \
             prfl_hgts.o \
             prfl_htbl.o \
             prfl_init_table.o \
             prfl_lwpm.o \
             prfl_read_table.o \
             prfl_rexp.o \
             prfl_rtbl.o \
             prfl_specification.o \
             prfl_thomson.o \
             prob_to_sigma.o \
             read_c_grd.o \
             read_grd.o \
             read_hdr.o \
             read_lwf.o \
             read_mds.o \
             recvr2.o \
             set_file_id.o \
             shift_array.o \
             shift_array2.o \
             sortr.o \
             str_count_list.o \
             str_get_item.o \
             str_length.o \
             str_lower.o \
             str_trim_char.o \
             str_upper.o \
             sw_drvequ.o \
             sw_extrap.o \
             sw_fctval.o \
             sw_initlr.o \
             sw_integ.o \
             sw_iterat.o \
             sw_next.o \
             sw_quartc.o \
             sw_rbars.o \
             sw_rplynm.o \
             sw_smatrx.o \
             sw_step.o \
             sw_uspoly.o \
             sw_wvgd.o \
             sw_xsave.o \
             wf_bndy.o \
             wf_driver.o \
             wf_f_fnctn.o \
             wf_htgain.o \
             wf_init.o \
             wf_integ.o \
             wf_itrate.o \
             wf_load.o \
             wf_ma2.o \
             wf_p_deriv.o \
             wf_quartc.o \
             wf_rbars.o \
             wf_r_mtrx.o \
             wf_scale.o \
             wf_step.o \
             wf_store.o \
             wf_ti_mtrx.o \
             wf_t_mtrx.o \
             wf_xfer.o \
             world_map.o \
             write_grd.o \
             write_hdr.o \
             write_lwf.o \
             write_mds.o \
             xc_add.o \
             xc_mdhnkl.o \
             xc_norme.o \
             xlineq.o
             
%.o : %.for
	$(FC) -c $(FFLAGS) -o $@ $<

all : lwpc.a Makefile

lwpc.a : $(object_files)
	ar r lwpc.a *.o
	
clean:
	rm -f lwpc.a *.o *~ *.gcda *.gcno


