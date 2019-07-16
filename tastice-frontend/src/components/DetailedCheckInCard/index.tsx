import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Card from "@material-ui/core/Card";
import CardHeader from "@material-ui/core/CardHeader";
import CardMedia from "@material-ui/core/CardMedia";
import CardContent from "@material-ui/core/CardContent";
import Avatar from "@material-ui/core/Avatar";
import IconButton from "@material-ui/core/IconButton";
import Typography from "@material-ui/core/Typography";
import { blue } from "@material-ui/core/colors";
import MoreVertIcon from "@material-ui/icons/MoreVert";
import lipton from "../../images/lipton.jpg";
import Link from "@material-ui/core/Link";
import { Link as RouterLink } from "react-router-dom";
import Rating from "material-ui-rating";

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 500,
    margin: `${theme.spacing(3)}px auto`
  },
  media: {
    height: 0,
    paddingTop: "56.25%"
  },
  avatar: {
    backgroundColor: blue[500]
  }
}));

const months: any = {
  0: "January",
  1: "February",
  2: "March",
  3: "April",
  4: "May",
  5: "June",
  6: "July",
  7: "August",
  8: "September",
  9: "October",
  10: "November",
  11: "December"
};

export const DetailedCheckInCard: React.FC<any> = ({ checkin }) => {
  const classes = useStyles();

  const checkinObject = {
    rating: checkin.rating,
    comment: checkin.comment,
    name: checkin.product.name,
    id: checkin.product.id,
    producer: checkin.product.producer,
    type: checkin.product.type
  };

  return (
    <div>
      <Card className={classes.card}>
        <CardMedia
          className={classes.media}
          image={lipton}
          title={checkinObject.name}
        />
        <CardContent>
          <Typography variant="h4" color="textSecondary" component="p">
            <Link component={RouterLink} to={`/product/${checkinObject.id}`}>
              {checkinObject.name}
            </Link>
          </Typography>
          <Typography variant="h5" color="textSecondary" component="p">
            {checkinObject.producer}
          </Typography>
          <Typography variant="h5" color="textSecondary" component="p">
            {checkinObject.type}
          </Typography>
          <Rating value={checkinObject.rating} max={5} />
          <Typography variant="h6" color="textSecondary" component="p">
            {checkinObject.comment}
          </Typography>
        </CardContent>
      </Card>
    </div>
  );
};
