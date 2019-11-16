import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:flutter_mfw/screen_adapter.dart';

import 'package:flutter_mfw/pages/location/page/location_recommend_page.dart';
import 'package:flutter_mfw/pages/location/page/location_reserve_page.dart';

import 'package:flutter_mfw/dao/location_dao.dart';
import 'package:flutter_mfw/model/location_model.dart';
import 'package:flutter_mfw/model/location_tababr_model.dart';

import 'package:flutter_mfw/pages/location/widget/location_sticky_category_widget.dart';
import 'package:flutter_mfw/pages/location/widget/location_what_widget.dart';
import 'package:flutter_mfw/pages/location/widget/location_navbar_widget.dart';
import 'package:flutter_mfw/pages/location/widget/location_top_nav_widget.dart';
import 'package:flutter_mfw/pages/location/widget/location_adv_widget.dart';
import 'package:flutter_mfw/pages/location/widget/location_stycky_widget.dart';
import 'package:flutter_mfw/pages/location/widget/location_nearly_widget.dart';
class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with AutomaticKeepAliveClientMixin{


  var _pageController;

  var _selectedIndex = 0;

  var _scrollController;

  var _opacity = 0.0;

  WeatherModel _weatherModel;

  var _commListModel = <ListNavModel>[];
  var _categoryListModel = <ListNavModel>[];

  var _tabbarTagList = <LocationTababrModelDataTagList>[];

  var _wanfaList = <LocationTababrModelDataDatalistDataBusinesslist>[];
  var _advImageUrl;

  //控制是否显示 悬浮头像

  var _isShowSticky = false;

  //是否显示综合 下面的那个水平滚动列表
  var _isShowSynthesize = true;

  DataNavModel _nearlyNavModel;
  DataNavModel _cityGuideModel;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _pageController = PageController(initialPage: 0);

    _scrollController = ScrollController();
    _scrollController.addListener((){

      var offy =  _scrollController.position.pixels;



      if(offy >= 1009.0){
        if(_isShowSticky == false){
          setState(() {
            _isShowSticky = true;
          });
        }
      }else{
        if(_isShowSticky == true){
          setState(() {
            _isShowSticky = false;
          });
        }
      }
      _opacity = offy / 80.0;

      setState(() {
        _opacity = _opacity > 1.0 ? 1.0 : _opacity;
      });

    });

    _requestLocationData();


  }
  //请求推荐 预定数据

  void _reqiuestLocationStickyData(){
    LocationTabbarDao.fetch().then((result){

      setState(() {
        _tabbarTagList = result.data.tagList;
        for(var item in result.data.dataList){
          if(item.style == "horizontal_wanfa_list"){

            _wanfaList = item.data.businessList;
            break;
          }
        }
      });

    }).catchError((error){

    });
  }

  //请求顶部信息
  void _requestLocationData(){
    LocationDao.fetch().then((reslut){

      setState(() {

        _weatherModel = reslut.data.ex;
        for(var item in reslut.data.listModel){
          if(item.style == "common_icons"){
            _commListModel = item.dataNavModel.listNavModel;
          }
          if(item.style == "category_entrance"){
            _categoryListModel = item.dataNavModel.listNavModel;
          }
          if(item.style == "poi_card_v2"){
            _nearlyNavModel = item.dataNavModel;
          }
          if(item.style == "pois_together"){
            _cityGuideModel = item.dataNavModel;
          }
          if(item.style == "banner"){
            _advImageUrl = item.dataNavModel.listNavModel.first.img.image;
          }
        }
        _reqiuestLocationStickyData();
      });


    }).catchError((error){
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return  Stack(
      children: <Widget>[
        _tabbarController(),
        LocationNavbarWidget(opacity: _opacity),
        _isShowSticky == true ? Padding(child: _stickyHeader(),padding: EdgeInsets.only(top: ScreenAdapter.setHeight(176))) : Text("")
      ],
    );
  }

  // 悬浮header
  Widget _stickyHeader(){
    return _tabbarTagList.length == 0 ? Text("") : Column(
      children: <Widget>[
        LocationStyckyWidget(
          selectedIndex: _selectedIndex,
          onTap: (index){
            _pageController.jumpToPage(index);
          },
        ),
        LocationStickyCategoryWidget(
          selectIndex:  _selectedIndex,
          tabbarTagList: _tabbarTagList,
          onTap: (index){
            setState(() {
              _isShowSynthesize = index == 0 ? true : false;
            });
          },
        )
      ],
    );
  }
  Widget _tabbarController(){

    return DefaultTabController(

      length: 2,
      child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context,inner){
            return [

              SliverToBoxAdapter(
                child: LocationTopNavWidget(
                    weatherModel: _weatherModel,
                    commonList:_commListModel,
                    categorylList: _categoryListModel
                ),
              ),
              SliverToBoxAdapter(
                child: LocationAdvWidget(
                  advImageUrl: _advImageUrl,
                ),
              ),
              SliverToBoxAdapter(
                child: LocationNearlyWidget(
                  nearlyNavModel: _nearlyNavModel,
                ),
              ),
              SliverToBoxAdapter(

                child:  LocationWhatWidget(
                  cityGuideModel: _cityGuideModel,
                ),
              ),

              SliverToBoxAdapter(
                  child: _stickyHeader()
              ),

            ];
          },
          body: PageView(
            controller: _pageController,
            onPageChanged: (index){
              setState(() {
                _selectedIndex = index;
              });
            },
            children: <Widget>[
              LocationRecommendPage(
                isShowSynthesize: _isShowSynthesize,
                wanfaList: _wanfaList,
              ),
              LocationReservePage()
            ],
          )
      ),
    );
  }
}