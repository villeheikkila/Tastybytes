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
import Link from "@material-ui/core/Link";
import { Link as RouterLink } from "react-router-dom";
import Rating from "material-ui-rating";
import { ProductCard } from "../ProductCard";

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 700,
    margin: `${theme.spacing(3)}px auto`
  },
  media: {
    height: 0,
    paddingTop: "56.25%"
  },
  avatar: {
    backgroundColor: blue[500]
  },
  content: {
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

export const CheckInCard: React.FC<any> = ({ checkin }) => {
  const classes = useStyles();

  const checkinObject = {
    authorFirstName: checkin.author.firstName,
    authorLastName: checkin.author.lastName,
    authorId: checkin.author.id,
    comment: checkin.comment,
    rating: checkin.rating,
    name: checkin.product.name,
    id: checkin.product.id,
    producer: checkin.product.producer,
    type: checkin.product.type,
    date: new Date(checkin.createdAt)
  };

  const productObject = {
    name: checkin.product.name,
    id: checkin.product.id,
    producer: checkin.product.producer,
    category: checkin.product.type,
    subCategory: "moi"
  }

  return (
    <div>
      <Card className={classes.card}>
        <CardHeader
          avatar={
            <Avatar aria-label="Author" src={""} className={classes.avatar}>
              R
            </Avatar>
          }
          action={
            <IconButton aria-label="Settings">
              <MoreVertIcon />
            </IconButton>
          }
          title={
            <Typography variant="h6" color="textSecondary" component="p">
              <Link
                component={RouterLink}
                to={`/user/${checkinObject.authorId}`}
              >
                {checkinObject.authorFirstName} {checkinObject.authorLastName}
              </Link>
            </Typography>
          }
          subheader={`${checkinObject.date.getDate()} ${
            months[checkinObject.date.getMonth()]
            }, ${checkinObject.date.getFullYear()}
          `}
        />
        <ProductCard product={productObject} />
        <CardContent className={classes.content}>
          <Typography variant="h6" color="textSecondary" component="p">
            Rating
            <Rating value={checkinObject.rating} max={5} />
          </Typography>
          <Typography variant="h6" color="textSecondary" component="p">
            Comment:{" "}
            {checkinObject.comment}
          </Typography>
        </CardContent>
      </Card>
    </div>
  );
};
